### Step1
You are given an `m x n` integer array `grid`. There is a robot initially located at the top-left corner (i.e., grid[0][0]). The robot tries to move to the **bottom-right** corner (i.e., grid[m - 1][n - 1]). The robot can only move either down or right at any point in time.

An obstacle and space are marked as 1 or 0 respectively in grid. A path that the robot takes cannot include any square that is an obstacle.

Return the number of possible unique paths that the robot can take to reach the bottom-right corner.

The testcases are generated so that the answer will be less than or equal to 2 * 10^9.

Constraints:
- m == obstacleGrid.length
- n == obstacleGrid[i].length
- 1 <= m, n <= 100
- obstacleGrid[i][j] is 0 or 1.

Ex1.
Input: obstacleGrid = [[0,0,0],[0,1,0],[0,0,0]]
Output: 2
Explanation: There is one obstacle in the middle of the 3x3 grid above.
There are two ways to reach the bottom-right corner:
1. Right -> Right -> Down -> Down
2. Down -> Down -> Right -> Right

Ex2.
Input: obstacleGrid = [[0,1],[0,0]]
Output: 1

Ex3.
Input: obstacleGrid = [[0,1],[1,0]]
Output: 0

Ex4.
Input: obstacleGrid = [[0,0,0],[0,0,0],[0,1,0]]
Output: 3

Edge Cases
In: [1]
Out: 1

In: [[0,0],[0,1]]
Out: 0

Approach
- 2通りずつ分岐する time complexity: 最悪O((m+n-2)C(m-1))
- DP time complexity: O(nm)
    - dp[i][j]は(i,j)までのパターン数
    - (i, j)が1のときはスキップ
    - dp[i] = dp[i-1][j] + dp[i][j-1]
    - 上記の更新則で(i-1, j)が1, (i, j-1)が1の時を考慮し、更新則を場合わけ
    - よく考えてみると、上記の場合わけは必要がない
    - return dp[m][n]

Accept
```py
class Solution:
    def uniquePathsWithObstacles(self, obstacleGrid: List[List[int]]) -> int:
        if len(obstacleGrid) == 0 or len(obstacleGrid[0]) == 0:
            return 0

        num_rows = len(obstacleGrid)
        num_cols = len(obstacleGrid[0])
        num_unique_path_ending_at = [[0] * num_cols for _ in range(num_rows)]
        for c in range(num_cols):
            if obstacleGrid[0][c] == 1:
                break

            num_unique_path_ending_at[0][c] = 1

        for r in range(num_rows):
            if obstacleGrid[r][0] == 1:
                break

            num_unique_path_ending_at[r][0] = 1
        for r in range(1, num_rows):
            for c in range(1, num_cols):
                if obstacleGrid[r][c] == 1:
                    num_unique_path_ending_at[r][c] = 0
                    continue

                num_unique_path_ending_at[r][c] = num_unique_path_ending_at[r - 1][c] + num_unique_path_ending_at[r][c - 1]
            
        return num_unique_path_ending_at[num_rows - 1][num_cols - 1]
```
🤖レビュー
- `num_unique_path_ending_at` => `num_unique_paths_ending_at`が正確. `path_counts`とかも良い
- 空間計算量をO(n)に落とせるか？
    - `num_unique_path_ending_at` = 「r行目まで処理した時点での、各列に到達できるパス数」とする
    - `num_unique_path_ending_at[c] = num_unique_path_ending_at[c] + num_unique_path_ending_at[c - 1]`という更新則にする
1次元にすると、0列目の初期化部分(r行目まで処理した時点で0列目に到達できるパス数)を移動しないといけない。移動する場所はrをイテレーションしているループの中での初期化。
rが更新されるたびに、
- 0列目に障害物がある場合、`num_unique_path_ending_at[0] = 0`
- 一度過去の0列目に障害物が現れていたら`num_unique_path_ending_at[0]`は障害の有無に関わらず0になる
- 過去の行で、更新された`num_unique_path_ending_at[0]`を上書きする
```py
class Solution:
    def uniquePathsWithObstacles(self, obstacleGrid: List[List[int]]) -> int:
        if len(obstacleGrid) == 0 or len(obstacleGrid[0]) == 0:
            return 0
        
        num_rows = len(obstacleGrid)
        num_cols = len(obstacleGrid[0])
        if obstacleGrid[0][0] == 1 or obstacleGrid[num_rows - 1][num_cols - 1] == 1:
            # これがないとだめなのは, for r in range(1, num_rows):でcan_reach_to_col0 =Trueになるべき部分がインデックスが１から始まっているので無視されるから
            return 0

        num_unique_paths = [0] * num_cols
        for c in range(num_cols):
            if obstacleGrid[0][c] == 1:
                break

            num_unique_paths[c] = 1

        # column0に到達できるかどうかを管理するフラグ
        can_reach_to_col0 = True
        for r in range(1, num_rows):
            if obstacleGrid[r][0] == 1:
                can_reach_to_col0 = False

            if can_reach_to_col0:
                num_unique_paths[0] = 1
            else:
                num_unique_paths[0] = 0
            
            for c in range(1, num_cols):
                if obstacleGrid[r][c] == 1:
                    num_unique_paths[c] = 0
                    continue

                num_unique_paths[c] += num_unique_paths[c - 1]

        return num_unique_paths[num_cols - 1]
```
- フラグなしでこう(`num_unique_paths[0] = 0 if obstacleGrid[r][0] == 1 else num_unique_paths[0]`)も書けるが、「過去に障害物があれば0が伝搬している」という前提が含まれているので素直に読めない

- 初期化自体をすべてループの中にもってくればシンプルになった
```py
class Solution:
    def uniquePathsWithObstacles(self, obstacleGrid: List[List[int]]) -> int:
        if len(obstacleGrid) == 0 or len(obstacleGrid[0]) == 0:
            return 0
        
        num_rows = len(obstacleGrid)
        num_cols = len(obstacleGrid[0])
        num_unique_paths_per_row = [0] * num_cols
        num_unique_paths_per_row[0] = 1
        for r in range(num_rows):
            for c in range(num_cols):
                if obstacleGrid[r][c] == 1:
                    num_unique_paths_per_row[c] = 0
                    continue

                if c > 0: # c = 0のときはc - 1が存在しないため
                    num_unique_paths_per_row[c] += num_unique_paths_per_row[c - 1]

        return num_unique_paths_per_row[num_cols - 1]
```
## Step2

## 他の人のPRからのコメント・学び

### コードレビュー観点

**定数はモジュールレベルかクラスのstatic変数として定義する**
> OBSTACLEは外部でも使うと考えられるのでグローバル変数かSolutionのstatic変数として定義するのがいいと思います！

([olsen-blue/Arai60#34](https://github.com/olsen-blue/Arai60/pull/34))

PEP8にも「Constants are usually defined on a module level」とある。関数内の定数はノイズになりやすい。
- https://peps.python.org/pep-0008/#constants

---

**`num_of_` という命名は冗長**
> num_という命名はthe number of ...という意味・プラクティスなので、num_of_pathsはnum_pathsでいいと思います！

([olsen-blue/Arai60#34](https://github.com/olsen-blue/Arai60/pull/34))

---

**変数名のスコープと長さのトレードオフ**
> The general rule of thumb is that the length of a name should be proportional to the size of its scope and inversely proportional to the number of times that it is used within that scope.
> ([Go Google Style Guide](https://google.github.io/styleguide/go/decisions#variable-names))

([olsen-blue/Arai60#34](https://github.com/olsen-blue/Arai60/pull/34)) — `r, c` のような短い変数名は、スコープが狭く頻繁に使われる場合は自然。

---

**配るDPと貰うDP**

([tom4649/Coding#32](https://github.com/tom4649/Coding/pull/32))

- **貰うDP（今回の実装）**: `dp[r][c] = dp[r-1][c] + dp[r][c-1]` — 書きやすく読みやすい
- **配るDP**: 今のセルの値を右・下のセルに加算していく — 最終行の処理など制御が複雑になりやすい
- 「配るよりも貰う方が書きやすい」はこの問題では概ね同意。2次元テーブルの方が `unique_paths_per_row` の入れ替えが不要で見通しが良い

参考: https://algo-method.com/descriptions/78

---

### 別解：top-down（再帰＋メモ化）

([naoto-iwase/leetcode#39](https://github.com/naoto-iwase/leetcode/pull/39))

```python
from functools import cache

class Solution:
    def uniquePathsWithObstacles(self, obstacleGrid: List[List[int]]) -> int:
        @cache
        def move_to(row, col):
            if obstacleGrid[row][col] == 1:
                return 0
            if row == 0 and col == 0:
                return 1
            if row == 0:
                return move_to(0, col - 1)
            if col == 0:
                return move_to(row - 1, 0)
            return move_to(row - 1, col) + move_to(row, col - 1)
        
        return move_to(len(obstacleGrid) - 1, len(obstacleGrid[0]) - 1)
```

- 障害物・境界などあらゆる「0になるパターン」でearly returnになるのがtop-downの利点
- 再帰の最大深さは `row + col - 2`（マンハッタン距離）

---

### 別解：2重forループを1本にする

([Fuminiton/LeetCode#34](https://github.com/Fuminiton/LeetCode/pull/34) での実装)

エッジ初期化を分けず、`h > 0` / `w > 0` の条件分岐で1本のループに統合できる：

```python
sum_paths[0][0] = 1
for h in range(height):
    for w in range(width):
        if obstacleGrid[h][w] == OBSTACLE:
            continue
        if h > 0:
            sum_paths[h][w] += sum_paths[h - 1][w]
        if w > 0:
            sum_paths[h][w] += sum_paths[h][w - 1]
```

エッジ初期化を先に分けた方が「初期化と遷移の分離」が明確で読みやすいが、このパターンも一般的。

---

### 言語の内部実装：分岐予測とパイプライン

([olsen-blue/Arai60#34](https://github.com/olsen-blue/Arai60/pull/34))

> コンパイラ言語ではif文（分岐命令）は分岐予測に失敗するとパイプラインをやり直す必要があり、他の命令より時間がかかる。なので、for文の中のif文は分けた方が速度・可読性の面で良い。

ただしこれはPythonには当てはまらない（インタプリタ言語自体が大量の分岐命令を使うため）。CやRustで最適化が必要な場合に意識すること。

> そもそも、そんなに速度が気になるならば50倍くらい遅い Python を使うべきではないという話になる。コードを書くというのはすべて地雷の埋設（使われなくなるまでに爆発しなければ勝ち）くらいに思っておくといいでしょう。

```py
class Solution:
    def uniquePathsWithObstacles(self, obstacleGrid: List[List[int]]) -> int:
        if not obstacleGrid or not obstacleGrid[0]:
            return 0
        
        num_rows = len(obstacleGrid)
        num_cols = len(obstacleGrid[0])
        num_paths_ending_at = [[0] * num_cols for _ in range(num_rows)]
        for i in range(num_rows):
            if obstacleGrid[i][0] == 1:
                break

            num_paths_ending_at[i][0] = 1
        for j in range(num_cols):
            if obstacleGrid[0][j] == 1:
                break

            num_paths_ending_at[0][j] = 1
        for i in range(1, num_rows):
            for j in range(1, num_cols):
                if obstacleGrid[i][j] == 1:
                    num_paths_ending_at[i][j] = 0
                    continue

                num_paths_ending_at[i][j] = num_paths_ending_at[i - 1][j] + num_paths_ending_at[i][j - 1]

        return num_paths_ending_at[num_rows - 1][num_cols - 1]
```