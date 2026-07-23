from .collector_interface import Collector


class SavedTracksCollector(Collector):
    def __init__(self):
        super().__init__()

    def collect(self):
        limit = 50
        offset = 0
        total_collected = 0

        try:
            while True:
                results = self.client.current_user_saved_tracks(
                    limit=limit,
                    offset=offset
                )
                items = results.get("items", [])

                if not items:
                    break

                for item in items:
                    track = item.get("track")
                    added_at = item.get("added_at")

                    if not track:
                        continue

                    track = self.save_track_with_details(track)

                    self.repository.save_saved_track(
                        track.get("id"),
                        added_at
                    )

                    total_collected += 1

                if results.get("next") is None:
                    break

                offset += limit

            if total_collected == 0:
                print("Nenhuma musica salva encontrada.")
            else:
                print(f"{total_collected} musicas salvas coletadas.")

            self.repository.close()
        except Exception as error:
            self.repository.connection.rollback()
            print("Erro durante a coleta. Transacao desfeita.")
            raise error
