from .collector_interface import Collector


class UserProfileCollector(Collector):
    def __init__(self):
        super().__init__()

    def collect(self):
        try:
            user = self.client.current_user()
            self.repository.save_user(user)
            self.repository.close()
            print("Perfil do usuario coletado.")
        except Exception as error:
            self.repository.connection.rollback()
            print("Erro durante a coleta. Transacao desfeita.")
            raise error
