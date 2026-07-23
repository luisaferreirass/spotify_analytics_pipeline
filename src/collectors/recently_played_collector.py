from .collector_interface import Collector


class RecentlyPlayedCollector(Collector):
    def __init__(self):
        super().__init__()

    def collect(self):
        results = self.client.current_user_recently_played(limit=50)
        items = results.get("items", [])

        if not items:
            print("Nenhuma musica recente encontrada.")
            self.repository.close()
            return

        try:
            for item in items:
                track = item.get("track")
                played_at = item.get("played_at")

                if not track:
                    continue

                track = self.save_track_with_details(track)

                self.repository.save_recently_played(
                    track.get("id"),
                    played_at
                )

            self.repository.close()
        except Exception as error:
            self.repository.connection.rollback()
            print("Erro durante a coleta. Transacao desfeita.")
            raise error
