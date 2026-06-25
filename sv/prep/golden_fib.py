#!/usr/bin/env python3


def fibonacci(i: int) -> int:
    if (i == 0 or i == 1):
        return i
    else:
        return fibonacci(i-1) + fibonacci(i-2)


def main() -> list[int]:
    """ Return N fib sequence numbers """
    return [fibonacci(i) for i in range(21)]
    


if __name__ == '__main__':
    print(main())
