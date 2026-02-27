from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any
import importlib.util
import sys
from pathlib import Path

app = FastAPI(
    title="Skills Executor API",
    description="API для выполнения Python скриптов (skills)",
    version="1.0.0"
)

SKILLS_DIR = Path(__file__).parent / "skills"

class ExecuteRequest(BaseModel):
    skill_name: str
    params: Optional[Dict[str, Any]] = None
    timeout: Optional[int] = None

class ExecuteResponse(BaseModel):
    success: bool
    result: Any
    error: Optional[str] = None


def load_skill(skill_name: str):
    """Динамически загружает скрипт из папки skills"""
    skill_file = SKILLS_DIR / f"{skill_name}.py"
    
    if not skill_file.exists():
        raise HTTPException(
            status_code=404, 
            detail=f"Skill '{skill_name}' not found at {skill_file}"
        )
    
    spec = importlib.util.spec_from_file_location(skill_name, skill_file)
    module = importlib.util.module_from_spec(spec)
    sys.modules[skill_name] = module
    spec.loader.exec_module(module)
    
    return module


@app.post("/execute", response_model=ExecuteResponse)
async def execute_skill(request: ExecuteRequest):
    """
    Выполняет Python скрипт из папки skills
    """
    try:
        # Загружаем skill
        skill_module = load_skill(request.skill_name)
        
        # Проверяем наличие функции main
        if not hasattr(skill_module, 'main'):
            raise HTTPException(
                status_code=500,
                detail=f"Skill '{request.skill_name}' должен содержать функцию main()"
            )
        
        # Выполняем скрипт с параметрами
        params = request.params or {}
        
        import signal
        
        def timeout_handler(signum, frame):
            raise TimeoutError(f"Skill '{request.skill_name}' превысил таймаут")
        
        # Устанавливаем таймаут если указан
        if request.timeout:
            signal.signal(signal.SIGALRM, timeout_handler)
            signal.alarm(request.timeout)
        
        try:
            result = skill_module.main(**params)
        finally:
            if request.timeout:
                signal.alarm(0)
        
        return ExecuteResponse(
            success=True,
            result=result,
            error=None
        )
        
    except TimeoutError as e:
        return ExecuteResponse(
            success=False,
            result=None,
            error=str(e)
        )
    except HTTPException:
        raise
    except Exception as e:
        return ExecuteResponse(
            success=False,
            result=None,
            error=f"{type(e).__name__}: {str(e)}"
        )


@app.get("/skills")
async def list_skills():
    """Возвращает список доступных skills"""
    skills = []
    if SKILLS_DIR.exists():
        for file in SKILLS_DIR.glob("*.py"):
            if file.name != "__init__.py":
                skills.append(file.stem)
    return {"skills": skills}


@app.get("/")
async def root():
    return {
        "message": "Skills Executor API",
        "endpoints": {
            "POST /execute": "Выполнить skill",
            "GET /skills": "Список доступных skills"
        }
    }
