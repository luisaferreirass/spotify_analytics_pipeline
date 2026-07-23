from .collector_interface import Collector


class TopArtistsCollector(Collector):
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
                results = self.client.current_user_top_artists(
                    limit=50,
                    offset=0,
                    time_range=time_range
                )
                artists = results.get("items", [])

                for position, artist in enumerate(artists, start=1):
                    self.save_artist_with_details(artist)
                    self.repository.save_top_artist_snapshot(
                        artist.get("id"),
                        time_range,
                        position
                    )

                    total_collected += 1

            if total_collected == 0:
                print("Nenhum top artista encontrado.")
            else:
                print(f"{total_collected} top artistas coletados.")

            self.repository.close()
        except Exception as error:
            self.repository.connection.rollback()
            print("Erro durante a coleta. Transacao desfeita.")
            raise error
