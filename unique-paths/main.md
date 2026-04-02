## Step1
There is a robot on an `m x n` grid. The robot is initially located at the top-left corner (i.e., grid[0][0]). The robot tries to move to the bottom-right corner (i.e., grid[m - 1][n - 1]). The robot can only move either down or right at any point in time.

Given the two integers `m` and `n`, return the number of possible unique paths that the robot can take to reach the bottom-right corner.

The test cases are generated so that the answer will be less than or equal to 2 * 10^9.

Ex1.
Input: m = 3, n = 7
Output: 28

Ex2.
Input: m = 3, n = 2
Output: 3
Explanation: From the top-left corner, there are a total of 3 ways to reach the bottom-right corner:
1. Right -> Down -> Down
2. Down -> Down -> Right
3. Down -> Right -> Down

Constraints:
1 <= m, n <= 100

Approach
- 今いる位置から次にいけるのが2通りなので2つのパスに再帰的に展開してgoalに達したらbreak

時間計算量: O(2^(m+n))
空間計算量: O(m+n) //再帰の深さは最大`m+n-2`
m = n = 100だとして、時間計算量は10^60くらい（2^10≒10^3）なので明らかにTLE
最適化を考える。上記の解法をそれぞれのマス`(i,j)`をゴールとするパターン数をメモ化して考えれば良さそう

ボトムアップDP

時間計算量: O(mn)
空間計算量: O(mn)

```py
class Solution:
    def uniquePaths(self, m: int, n: int) -> int:
        num_unique_paths_goal_at = [[0] * n for _ in range(m)]
        for i in range(m):
            num_unique_paths_goal_at[i][0] = 1
        for j in range(n):
            num_unique_paths_goal_at[0][j] = 1
        for i in range(1, m):
            for j in range(1, n):
               num_unique_paths_goal_at[i][j] = num_unique_paths_goal_at[i - 1][j] + num_unique_paths_goal_at[i][j - 1]

        return num_unique_paths_goal_at[m - 1][n - 1]
```

🤖レビュー
-  正しいですが、最初から1で初期化すれば1ループ省けます： num_unique_paths_goal_at = [[1] * n for _ in range(m)]
- Space: O(mn) → これをO(n)に落とせますか？

二番目の指摘について考えてみる. iに着目するとi-1にしか依存していないので、num_unique_paths_goal_at[j]に`i - 1`の結果を格納しておけば良さそう

```py
class Solution:
    def uniquePaths(self, m: int, n: int) -> int:
        num_unique_paths_to = [1] * n
        for i in range(1, m):
            for j in range(1, n):
               num_unique_paths_to[j] += num_unique_paths_to[j - 1]

        return num_unique_paths_to[n - 1]
```

## Step2

### 他のPRからのコメント・学び

---

#### 変数名

**[philip82148 → olsen-blue]** [コメント](https://github.com/olsen-blue/Arai60/pull/33/files#r1966730313)
> mとnの命名も工夫できると良いと思っています！`num_rows`、`num_cols`(num_columns)等がいいかなと思います！

引数名をそのまま使うのではなく、意図を示す名前に置き換えると読みやすい。

**[philip82148 → Fuminiton]** [コメント](https://github.com/Fuminiton/LeetCode/pull/33/files#r1966730313)
> `sum_paths`という命名はあまり見かけず、`num_paths`の方が「the number of ...」という意味で分かりやすい。`the sum of paths`はあまり意味が通らない。

**[Yoshiki-Iwasa → Fuminiton]** [コメント](https://github.com/Fuminiton/LeetCode/pull/33)
> `paths`という命名の配列を見ると「経路」を表すオブジェクトの配列を想像するので、`num_of_paths`等にすると驚きが少ない。変数名が長くなるなら、コメントで`paths[i][j]`が何を示すかを最初に書くのも手。

---

#### 2次元リストの初期化バグ（Pythonあるある）

**[oda → Fuminiton]** [コメント](https://github.com/Fuminiton/LeetCode/pull/33)
> `[[0] * num_cols] * num_rows`とすると、`[0, 0, ..., 0]`への参照が`num_rows`回作られる。数字はimmutableなので`[0] * n`は問題ないが、リストはmutableなので2次元配列の外側を`* m`で複製するとすべての行が同一オブジェクトを指してしまう。

```python
grid = [[0] * 2] * 3
grid[0][0] = 1
print(grid)  # [[1, 0], [1, 0], [1, 0]] ← 全行が変わってしまう
```

正しくは `[[0] * n for _ in range(m)]`

---

#### メモリレイアウトとループ順序

**[oda → saagchicken]** [コメント](https://github.com/saagchicken/coding_practice/pull/19)
> 二重ループは右の添字が内側になるように回す。C++等だとメモリの配置と速度にわずかに関係がある（row-major order）。Pythonではあまり関係ないが、意識しておくと良い。

---

#### 別解：組み合わせ (nCr)

**[naoto-iwase, fuga-98, olsen-blue 等]**

右移動 `n-1` 回と下移動 `m-1` 回の並べ方の総数なので、

$${}_{m+n-2} C_{m-1}$$

Pythonでは `math.comb(m + n - 2, m - 1)` で O(m) time, O(1) space で解ける。

```python
import math
class Solution:
    def uniquePaths(self, m: int, n: int) -> int:
        return math.comb(m + n - 2, m - 1)
```

ただし、Unique Paths IIのように障害物が追加される要件変更に対応できないため、DPの方が拡張性は高い。

---

#### math.combの内部実装（CPython）

**[oda, naoto-iwase]** [CPython mathintegermodule.c](https://github.com/python/cpython/blob/main/Modules/mathintegermodule.c)

ライブラリ関数は典型的な入力分布を前提に高度にチューニングされている：
- 64bitに収まる範囲を閾値テーブルで精密に切り取り、収まる場合はテーブル参照×乗算×ビットシフトのみで完了（多倍長計算ゼロ）
- 収まらない場合は分割統治で多倍長乗算の特性に合わせて処理
- 「先に決め打ち高速経路を広く張る → 落ちたら分割統治 → 各所で再び小経路に戻す」という三段構え

---

#### brute forceの計算量の正確な見積もり

**[oda → olsen-blue]** [コメント](https://github.com/olsen-blue/Arai60/pull/33/files#r1966573776)

brute forceの再帰木を考えると、葉（return 1）の数はゴールへの経路数そのものに等しい。
経路は「下移動 m-1 回、右移動 n-1 回の並べ方」なので葉の数は **(m+n-2)C(m-1)**。
内部ノード数 = 葉の数 - 1（二分木の性質より）なので、全ノード数 = 2*(m+n-2)C(m-1) - 1。

つまり時間計算量は **O((m+n-2)C(m-1))** が正確。O(2^(m+n)) はゆるい上界。

---

#### `@cache` デコレータによるトップダウンDP

**[olsen-blue]** [PR](https://github.com/olsen-blue/Arai60/pull/33)

再帰関数に `@cache` をつけるだけでメモ化が自動的に行われる：

```python
from functools import cache

class Solution:
    @cache
    def uniquePaths(self, m: int, n: int) -> int:
        if m == 1 or n == 1:
            return 1
        return self.uniquePaths(m-1, n) + self.uniquePaths(m, n-1)
```

`@cache` は `functools.lru_cache(maxsize=None)` の糖衣構文（Python 3.9+）。
ただし `self` もキャッシュキーに含まれるため、メソッドに使う場合は注意が必要。
スタンドアロン関数に使うのがより一般的。