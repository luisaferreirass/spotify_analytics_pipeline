def validate_spotify_env():
    pass


def validate_postgres_env(db, user, password, host, port):
    if not db:
        raise ValueError("POSTGRES_DB não foi definido no .env")

    if not user:
        raise ValueError("POSTGRES_USER não foi definido no .env")

    if not password:
        raise ValueError("POSTGRES_PASSWORD não foi definido no .env")

    if not host:
        raise ValueError("POSTGRES_HOST não foi definido no .env")

    if not port:
        raise ValueError("POSTGRES_PORT não foi definido no .env")