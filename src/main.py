import sys
from collector_runner import CollectorRunner
from services.parser import parse_args

def main():
    args = parse_args()
    collector_runner = CollectorRunner()
    collector_runner.run(args.mode)


if __name__ == "__main__":
    main()
