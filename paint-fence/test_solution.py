from functools import cache

def num_ways(n: int, k: int) -> int:
    @cache
    def num_ways_helper(n: int):
        if n == 1:
            return k
        if n == 2:
            return k * k
        return (k - 1) * (num_ways_helper(n - 2) + num_ways_helper(n - 1))

    return num_ways_helper(n)


def brute_force(n: int, k: int) -> int:
    from itertools import product
    count = 0
    for combo in product(range(k), repeat=n):
        valid = True
        for i in range(2, n):
            if combo[i] == combo[i-1] == combo[i-2]:
                valid = False
                break
        if valid:
            count += 1
    return count


test_cases = [
    (3, 2, 6),
    (2, 2, 4),
    (1, 2, 2),
    (2, 1, 1),
    (1, 1, None),
    (1, 5, None),
    (3, 3, None),
    (4, 2, None),
    (5, 3, None),
    (10, 4, None),
]

for n, k, expected in test_cases:
    result = num_ways(n, k)
    if expected is None:
        expected = brute_force(n, k)
    status = "OK" if result == expected else "FAIL"
    print(f"[{status}] n={n}, k={k} => {result} (expected {expected})")
