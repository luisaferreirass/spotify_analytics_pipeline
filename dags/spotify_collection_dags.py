from __future__ import annotations

from datetime import datetime, timedelta

from airflow.decorators import dag, task

from collector_runner import CollectorRunner


DEFAULT_ARGS = {
    "owner": "spotify-analytics",
    "depends_on_past": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}


def run_collector(mode: str) -> None:
    CollectorRunner().run(mode)


@dag(
    dag_id="spotify_quick_collection",
    description="Coleta perfil do usuario e musicas tocadas recentemente.",
    default_args=DEFAULT_ARGS,
    start_date=datetime(2026, 1, 1),
    schedule="*/30 * * * *",
    catchup=False,
    max_active_runs=1,
    tags=["spotify", "collection", "quick"],
)

def spotify_quick_collection():
    @task(task_id="collect_recent_activity")
    def collect_recent_activity():
        run_collector("quick")

    collect_recent_activity()


@dag(
    dag_id="spotify_library_collection",
    description="Atualiza musicas e albuns salvos na biblioteca.",
    default_args=DEFAULT_ARGS,
    start_date=datetime(2026, 1, 1),
    schedule="0 3 * * *",
    catchup=False,
    max_active_runs=1,
    tags=["spotify", "collection", "library"],
)

def spotify_library_collection():
    @task(task_id="collect_saved_library")
    def collect_saved_library():
        run_collector("library")

    collect_saved_library()


@dag(
    dag_id="spotify_rankings_collection",
    description="Registra snapshots dos rankings de artistas e musicas.",
    default_args=DEFAULT_ARGS,
    start_date=datetime(2026, 1, 1),
    schedule="0 4 * * *",
    catchup=False,
    max_active_runs=1,
    tags=["spotify", "collection", "rankings"],
)

def spotify_rankings_collection():
    @task(task_id="collect_top_tracks_and_artists")
    def collect_top_tracks_and_artists():
        run_collector("rankings")

    collect_top_tracks_and_artists()


@dag(
    dag_id="spotify_full_collection",
    description="Executa todos os coletores do projeto Spotify.",
    default_args=DEFAULT_ARGS,
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["spotify", "collection", "full"],
)

def spotify_full_collection():
    @task(task_id="collect_everything")
    def collect_everything():
        run_collector("full")

    collect_everything()


spotify_quick_collection()
spotify_library_collection()
spotify_rankings_collection()
spotify_full_collection()
