import argparse

def parse_args():
    parser = argparse.ArgumentParser(
        description="Executa os coletores do Spotify"
    )

    parser.add_argument(
        "--mode",
        choices=["quick", "library", "rankings", "full"],
        default="quick",
        help="Modo de coleta"
    )

    return parser.parse_args()
