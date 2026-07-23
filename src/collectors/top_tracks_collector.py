from .collector_interface import Collector


class TopTracksCollector(Collector):
    TIME_RANGES = [
        "short_term",
        "medium_term",
        "long_term"
    ]

    def __init__(self):
        super().__init__()

    def collect(self):
        total_collected = 0

        try:
            for time_range in self.TIME_RANGES:
                results = self.client.current_user_top_tracks(
                    limit=50,
                    offset=0,
                    time_range=time_range
                )
                tracks = results.get("items", [])

                for position, track in enumerate(tracks, start=1):
                    track = self.save_track_with_details(track)

                    self.repository.save_top_track_snapshot(
                        track.get("id"),
                        time_range,
                        position
                    )

                    total_collected += 1

            if total_collected == 0:
                print("Nenhuma top musica encontrada.")
            else:
                print(f"{total_collected} top musicas coletadas.")

            self.repository.close()
        except Exception as error:
            self.repository.connection.rollback()
            print("Erro durante a coleta. Transacao desfeita.")
            raise error
