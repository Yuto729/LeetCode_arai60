## Step1
Number of Islandsと同じようにDFSで解く. 前問とは異なり, 同じノードを2回数えてしまうと答えがずれるのでvisitedやstackへの格納を正確に行うことが重要.
時間計算量: O(M ✕ N)
```py
class Solution:
    def maxAreaOfIsland(self, grid: List[List[int]]) -> int:
        if not grid:
            return 0

        m = len(grid)
        n = len(grid[0])
        LAND = 1
        WATER = 0
        visited = set()
        directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        def calculate_area_of_island(x, y):
            stack = [(x, y)]
            visited.add((x, y))
            area = 1
            while stack:
                x, y = stack.pop()
                for dx, dy in directions:
                    next_x = x + dx
                    next_y = y + dy
                    if (next_x, next_y) in visited:
                        continue

                    if not (0 <= next_x < m and 0 <= next_y < n):
                        continue
                    
                    if grid[next_x][next_y] == WATER:
                        continue

                    area += 1
                    stack.append((next_x, next_y))
                    visited.add((next_x, next_y))

            return area

        max_area = 0
        for i in range(m):
            for j in range(n):
                if grid[i][j] == LAND:
                    if (i, j) in visited:
                        continue

                    area = calculate_area_of_island(i, j)
                    max_area = max(max_area, area)

        return max_area
```
前問と同様に再帰DFS, BFS, Union-Findで書き直してみる(復習)

1. 再帰DFS
ポイント
- visitedに追加するタイミング
- areaをreturnすることで変数の破壊的変更を防ぐ
- area = calculate_area_of_island(i, j, 1)で面積の初期値は1にする
再帰DFSはスタックオーバーフローのリスクがある. 最悪深さO(M ✕ N)
```py
class Solution:
    def maxAreaOfIsland(self, grid: List[List[int]]) -> int:
        if not grid:
            return 0

        m = len(grid)
        n = len(grid[0])
        LAND = 1
        WATER = 0
        visited = set()
        directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        def calculate_area_of_island(x, y, area):
            visited.add((x, y))
            for dx, dy in directions:
                next_x = x + dx
                next_y = y + dy
                if (next_x, next_y) in visited:
                    continue

                if not (0 <= next_x < m and 0 <= next_y < n):
                    continue
                
                if grid[next_x][next_y] == WATER:
                    continue

                area += 1
                # visited.add((next_x, next_y)) ここでaddしても良い
                area = calculate_area_of_island(next_x, next_y, area)

            return area

        max_area = 0
        for i in range(m):
            for j in range(n):
                if grid[i][j] == LAND:
                    if (i, j) in visited:
                        continue
                    
                    # visited.add((i, j))
                    area = calculate_area_of_island(i, j, 1)
                    max_area = max(max_area, area)

        return max_area
```

2. BFS

```py
class Solution:
    def maxAreaOfIsland(self, grid: List[List[int]]) -> int:
        if not grid:
            return 0

        m = len(grid)
        n = len(grid[0])
        LAND = 1
        WATER = 0
        visited = set()
        directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        def calculate_area_of_island(x, y, area):
            queue = deque()
            queue.append((x, y))
            visited.add((x, y))
            while queue:
                x, y = queue.popleft()
                for dx, dy in directions:
                    next_x = x + dx
                    next_y = y + dy
                    if (next_x, next_y) in visited:
                        continue

                    if not (0 <= next_x < m and 0 <= next_y < n):
                        continue
                    
                    if grid[next_x][next_y] == WATER:
                        continue

                    area += 1
                    visited.add((next_x, next_y))
                    queue.append((next_x, next_y))

            return area

        max_area = 0
        for i in range(m):
            for j in range(n):
                if grid[i][j] == LAND:
                    if (i, j) in visited:
                        continue
                    
                    area = calculate_area_of_island(i, j, 1)
                    max_area = max(max_area, area)

        return max_area
```
3. Union-Find
時間, 空間計算量: O(M ✕ N). UnionとFindの計算量はアッカーマン関数の逆関数
ポイント
- findで経路圧縮を実装する

```py
class UnionFind:
    def __init__(self, n):
        self.parents = list(range(n))
        self.area = [0] * n
    
    # 経路圧縮なし: 計算量はO(logn)
    # def find(self, x):
    #     if self.parents[x] == x:
    #         return x
        
    #     return self.find(self.parents[x])

    # 経路圧縮あり: 計算量O(α(n))
    def find(self, x):
        if self.parents[x] != x:
            self.parents[x] = self.find(self.parents[x])
        
        return self.parents[x]

    def union(self, x, y):
        parent_x = self.find(x)
        parent_y = self.find(y)
        if parent_x == parent_y:
            return

        if self.area[parent_x] < self.area[parent_y]:
            parent_x, parent_y = parent_y, parent_x
        
        self.parents[parent_y] = parent_x
        self.area[parent_x] += self.area[parent_y]
           
class Solution:
    def maxAreaOfIsland(self, grid: List[List[int]]) -> int:
        if not grid:
            return 0

        m = len(grid)
        n = len(grid[0])
        LAND = 1
        WATER = 0
        uf = UnionFind(m * n)
        for i in range(m):
            for j in range(n):
                if grid[i][j] == LAND:
                    uf.area[i * n + j] = 1

        for i in range(m):
            for j in range(n):
                if grid[i][j] == LAND:
                    idx = i * n + j
                    if j + 1 < n and grid[i][j + 1] == LAND:
                        uf.union(idx, idx + 1)
                    
                    if i + 1 < m and grid[i + 1][j] == LAND:     
                        uf.union(idx, idx + n)

        return max(uf.area)
```
## Step2 他の人のコードやコメントなどを見る
https://github.com/colorbox/leetcode/pull/32/changes/BASE..9e158c529cc75864b1ecad429cecfbe15e0723a0#r1898178545
> stack に追加する前に範囲チェックをするのも一つです。問題によっては計算量が変わることもあります。そうすると、範囲チェックをして追加という、同じ処理が繰り返されるので関数化をしたりラムダにしたりするのがいいでしょう。

- visitedをsetではなく, m * nの配列にするのも良さそう. `visited[i][j] = True`のような使い方

- 再帰DFSの解法の別の書き方
```py
def calculate_area_of_island(x, y):
    if not (0 <= x < m and 0 <= y < n):
        return 0
    
    if grid[x][y] == WATER:
        return 0
    
    if visited[x][y]:
        return 0

    visited[x][y] = True
    area = 1 # (x, y)の面積分
    for dx, dy in directions:
        area += calculate_area_of_island(x + dx, y + dy)

    return area
```

## Step3
```py
class Solution:
    def maxAreaOfIsland(self, grid: List[List[int]]) -> int:
        if not grid:
            return 0

        m = len(grid)
        n = len(grid[0])
        LAND = 1
        WATER = 0
        visited = set()
        directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        def calculate_area_of_island(x, y):
            stack = [(x, y)]
            visited.add((x, y))
            area = 1
            while stack:
                x, y = stack.pop()
                for dx, dy in directions:
                    next_x = x + dx
                    next_y = y + dy
                    if (next_x, next_y) in visited:
                        continue

                    if not (0 <= next_x < m and 0 <= next_y < n):
                        continue
                    
                    if grid[next_x][next_y] == WATER:
                        continue

                    area += 1
                    stack.append((next_x, next_y))
                    visited.add((next_x, next_y))

            return area

        max_area = 0
        for i in range(m):
            for j in range(n):
                if grid[i][j] == LAND:
                    if (i, j) in visited:
                        continue

                    area = calculate_area_of_island(i, j)
                    max_area = max(max_area, area)

        return max_area
```