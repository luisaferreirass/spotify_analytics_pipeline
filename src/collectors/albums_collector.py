from .collector_interface import Collector


class AlbumsCollector(Collector):
    def __init__(self):
        super().__init__()

    def collect(self):
        limit = 50
        offset = 0
        total_collected = 0

        try:
            while True:
                results = self.client.current_user_saved_albums(
                    limit=limit,
                    offset=offset
                )
                items = results.get("items", [])

                if not items:
                    break

                for item in items:
                    album = item.get("album")
                    added_at = item.get("added_at")

                    if not album:
                        continue

                    self.repository.save_album(album)

                    for artist in album.get("artists", []):
                        self.save_artist_with_details(artist)

                    self.repository.save_saved_album(
                        album.get("id"),
                        added_at
                    )

                    total_collected += 1

                if results.get("next") is None:
                    break

                offset += limit

            if total_collected == 0:
                print("Nenhum album salvo encontrado.")
            else:
                print(f"{total_collected} albuns salvos coletados.")

            self.repository.close()
        except Exception as error:
            self.repository.connection.rollback()
            print("Erro durante a coleta. Transacao desfeita.")
            raise error
