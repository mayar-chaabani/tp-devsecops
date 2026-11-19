from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings and configuration."""
    
    # Secrets: no default value, the app refuses to start if they are not provided
    DATABASE_URL: str
    
    # Application
    APP_NAME: str = "FastAPI Application"
    DEBUG: bool = True
    API_V1_PREFIX: str = "/api/v1"
    
    # Authentication
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 43200  # 30 days
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
        # Kubernetes mounts each secret as a file named after the setting
        secrets_dir="/run/secrets/app",
    )


settings = Settings()
