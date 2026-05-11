## Step1
グリッドのノードを順にたどっていくのでDFS/BFSで解けそう. グリッドを先頭から走査して"1"のときをスタートとしてDFSを適用する. DFSは隣接ノードを走査して"1"のときは探索の候補として加える. 探索の候補がなくなったとき島の探索を終了し, 島カウントを1つ増やす.
連結成分を見つける問題っぽい. 

細かい点
- 境界チェック
- スタート地点を見つけるときにすでに探索済みの点はスキップする

時間計算量: O(M*N). 空間計算量: O(M*N)(visitedの大きさ)
```py
class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        m = len(grid)
        n = len(grid[0])
        def visite_island(start_x, start_y):
            stack = [(start_x, start_y)]
            path_list = [(0, 1), (1, 0), (0, -1), (-1, 0)]
            while stack:
                x, y = stack.pop()
                visited.add((x, y))
                for path in path_list:
                    next_x = x + path[0]
                    next_y = y + path[1]
                    if next_x < 0 or next_x >= m or next_y < 0 or next_y >= n:
                        continue

                    if (next_x, next_y) in visited:
                        continue
                     
                    if grid[next_x][next_y] == "0":
                        continue
                    
                    stack.append((next_x, next_y))
            # ここでcount += 1をしても答えは同じ.

        count = 0
        visited = set()
        for i in range(m):
            for j in range(n):
                if (i, j) in visited:
                    continue

                if grid[i][j] == "1":
                    count += 1
                    visite_island(i, j)
        
        return count
```

上記のコードの問題点
- スタックからpopしたときに`visited`に追加しているので, 同じノードを追加する可能性がある. => TLEの原因
- 例: forループ内で(0, 1)と(1, 0)の両方から(1, 1)を探索候補として追加してしまう.
**visitedへのマークは必ずスタックへの追加とセットで行う.**
```py
def visite_island(start_x, start_y):
            stack = [(start_x, start_y)]
            path_list = [(0, 1), (1, 0), (0, -1), (-1, 0)]
            while stack:
                x, y = stack.pop()
                for path in path_list:
                    next_x = x + path[0]
                    next_y = y + path[1]
                    if next_x < 0 or next_x >= m or next_y < 0 or next_y >= n:
                        continue

                    if (next_x, next_y) in visited:
                        continue
                     
                    if grid[next_x][next_y] == "0":
                        continue
                    
                    stack.append((next_x, next_y))
                    ## ここ
                    visited.add((x, y))
```

inplaceでvisitedを使わずに解ける. 島番号を定義し, グリッドの各マスを島番号でうめていく.
- デメリット: 与えられた grid に破壊的な変更が加えられてしまう.

```py
class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        m = len(grid)
        n = len(grid[0])
        def find_island(start_x, start_y):
            stack = [(start_x, start_y)]
            path_list = [(0, 1), (1, 0), (0, -1), (-1, 0)]
            while stack:
                x, y = stack.pop()
                for path in path_list:
                    next_x = x + path[0]
                    next_y = y + path[1]
                    if next_x < 0 or next_x >= m or next_y < 0 or next_y >= n:
                        continue
                     
                    if grid[next_x][next_y] == "0" or grid[next_x][next_y] == island_number:
                        continue

                    stack.append((next_x, next_y))
                    grid[x][y] = island_number

        count = 0
        island_number = 0
        for i in range(m):
            for j in range(n):
                if grid[i][j] == "1":
                    count += 1
                    island_number += 1
                    find_island(i, j)

        return count
```

## Step2 他の人のコード・コメント集を読む
- https://github.com/Ryotaro25/leetcode_first60/pull/18/changes#r1676688022
> '1'や'0'といった値はconst WATER = '0'みたいに名前をつけてあげると読みやすい & 意図が伝わりやすいです.
`LAND` `WATER`を定義.
- `traverse_island`という変数名も良さそう.
- pathというよりdirection

DFS部分を再帰にした
ただ再帰だとコールスタック制限を考える必要がある（https://docs.python.org/3/library/sys.html#sys.setrecursionlimit）
- https://github.com/Fuminiton/LeetCode/pull/17#discussion_r1984361170 
> これ島自体が蛇のようになっていなくても、左右を優先して探索して、その後上下を探索するので、蛇腹状に埋まっていきます。
- pythonだとデフォルトで1000
- 今回のケースだと最悪M*Nになる

```py
def find_island(x, y):
    directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
    for direction in directions:
        neighbor_x = x + direction[0]
        neighbor_y = y + direction[1]
        if neighbor_x 0 or neighbor_x <= m or neighbor_y < 0 or neighbor_y >= n:
            continue
            
        if grid[neighbor_x][neighbor_y] == WATER or grid[neighbor_x][neighbor_y] == island_number:
            continue

        find_island(neighbor_x, neighbor_y)
        grid[x][y] = island_number
    
    return 
```

BFSで解く. 時間計算量: O(N*M), 空間計算量: O(min(M, N))
```py
class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        m = len(grid)
        n = len(grid[0])
        WATER = "0"
        LAND = "1"
        def find_island(x, y):
            directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
            queue = deque()
            queue.append((x, y))
            while queue:
                x, y = queue.popleft()
                for direction in directions:
                    neighbor_x = x + direction[0]
                    neighbor_y = y + direction[1]
                    if neighbor_x < 0 or neighbor_x >= m or neighbor_y < 0 or neighbor_y >= n:
                        continue

                    if grid[neighbor_x][neighbor_y] == WATER or grid[neighbor_x][neighbor_y] == island_number:
                        continue

                    queue.append((neighbor_x, neighbor_y))
                    grid[neighbor_x][neighbor_y] = island_number
            
            return

        count = 0
        island_number = 0
        for i in range(m):
            for j in range(n):
                if grid[i][j] == LAND:
                    count += 1
                    island_number += 1
                    find_island(i, j)

        return count
```
### BFSとDFSの比較
DFSが優れている場面
- 解がソースから離れたところにある
- 解の存在確認（到達可能かのみを知りたい場合）
- 経路の列挙をしたい（バックトラッキング）

BFSが優れている場面
- 最短経路を求める
- 解が近くにあることがわかっているとき

Union-Find
- Find: 要素が属するグループを見つける
- Union: 2つのグループを統合する
- ランク（木の高さの上限）が低い方やサイズが小さい方を大きい方の下に繋ぐことで効率よく統合ができる. O(logn)
計算量: アッカーマン関数の逆関数

```py
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.count = 0
    
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    
    def union(self, x, y):
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        
        self.parent[py] = px
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1

        # 統合すると連結成分が１つ減る
        self.count -= 1

class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        if not grid:
            return 0

        LAND = "1"
        WATER = "0"
        m, n = len(grid), len(grid[0])
        uf = UnionFind(m * n)
        # はじめは各陸地が独立した状態
        for i in range(m):
            for j in range(n):
                if grid[i][j] == LAND:
                    uf.count += 1
        
        for i in range(m):
            for j in range(n):
                if grid[i][j] == LAND:
                    idx = i * n + j
                    # 右と下だけチェックすれば十分
                    if j + 1 < n and grid[i][j + 1] == LAND:
                        uf.union(idx, idx + 1)
                    if i + 1 < m and grid[i + 1][j] == LAND:
                        uf.union(idx, idx + n)
        
        return uf.count
```


## Step3
```py
class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        if not grid:
            return 0
        
        m = len(grid)
        n = len(grid[0])
        LAND = "1"
        WATER = "0"

        def traverse_island(x, y):
            stack = [(x, y)]
            directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
            while stack:
                x, y = stack.pop()
                for direction in directions:
                    neighbor_x = x + direction[0]
                    neighbor_y = y + direction[1]
                    if not (0 <= neighbor_x < m and 0 <= neighbor_y < n):
                        continue
                    
                    if (neighbor_x, neighbor_y) in visited:
                        continue
                    
                    if grid[neighbor_x][neighbor_y] == WATER:
                        continue
                    
                    stack.append((neighbor_x, neighbor_y))
                    visited.add((neighbor_x, neighbor_y))

        visited = set()
        count = 0
        for i in range(m):
            for j in range(n):
                if (i, j) in visited:
                    continue
            
                if grid[i][j] == LAND:
                    count += 1
                    visited.add((i, j))
                    traverse_island(i, j)
        
        return count
```