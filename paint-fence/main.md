## Step1

There is a fence with n posts, each post can be painted with one of the k colors.
You have to paint all the posts such that no more than two adjacent fence posts have the same color.
Return the total number of ways you can paint the fence.

Example

1. normal
   Input: n,k = 3,2
   Output: 6

2. normal
   Input: n,k = 2,2
   Output: 4

3. normal
   Input: n,k = 1,2
   Output: 2

4. edge
   Input: n,k = 2,1
   Output: 1

Approach

- DP
  - num_ways(n, k)をn,kが与えられたときの組み合わせ数
  - num_ways(n, k) = kのうち一つ & num_ways(n-1, k) ただし末尾2つが重複するケースを除く

以上のところまで思いついたが、１つのDP配列だけでは解けなかった

- 末尾が2つのパターンを管理する配列をもう一つ用意する
  🤖AIにヒントをもらい実装
- 時間計算量O(N)
- 空間計算量O(N)

```py
class Solution:
    """
    @param n: non-negative integer, n posts
    @param k: non-negative integer, k colors
    @return: an integer, the total number of ways
    """
    def num_ways(self, n: int, k: int) -> int:
        num_ways = [0] * (n + 1)
        num_tail_two_duplicates = [0] * (n + 1)

        num_ways[1] = k
        for i in range(2, n + 1):
            # i番目のポストをi-1と同じ色にできる = i-1ポストのうち末尾2つが異なるパターン数
            num_tail_two_duplicates[i] = num_ways[i - 1] - num_tail_two_duplicates[i - 1]
            num_ways[i] = num_ways[i - 1] * k - num_tail_two_duplicates[i - 1]

        return num_ways[n]
```

レビュー

- `num_ways`はメソッドと同じ名前なので変えたほうが良い。ex. count_ways
  - メソッドを`numWays`にすればいいのでは

## Step2

- https://github.com/mamo3gr/arai60/pull/57
  同じやり方

### 他の解法

- same/diff DP
  - num_tail_two_duplicates = 末尾２つが同じ色 (same配列とする)に対し、diff配列（末尾２つが異なる色）を用意し、それぞれを更新する
  - 上記解法の２つの更新則を１つの漸化式にすることができる

- 空間計算量が1のやり方
  - O(n)の配列を２つ使っているが各ステップで直前の値しか使わないのでO(1)にできる
- 再帰 + @cache
- 組み合わせ論的アプローチ

### same/diff

一番標準的な方法
same[i]: post i, i-1が同じ色のパターン数
diff[i]: post i, i-1が異なる色のパターン数
以下の更新則で更新
answer = same[n] + diff[n]

- 時間計算量O(N)
- 空間計算量O(N)

```py
def numWays(self, n: int, k: int) -> int:
    same = [0] * (n + 1)
    diff = [0] * (n + 1)

    same[1] = 0
    diff[1] = k
    for i in range(2, n + 1):
        diff[i] = (k - 1) * (same[i - 1] + diff[i - 1])
        same[i] = diff[i - 1]

    return same[n] + diff[n]
```

- diff => `num_tail_two_different`, same => `num_tail_two_same`とかのほうが良さそう

また、2つの漸化式をまとめると,

```py
diff[i] = (k - 1) * (diff[i - 2] + diff[i - 1])
```

という１つの漸化式で書くことができ、答えは`diff[n - 1] + diff[n]`になる

- この場合diffという変数名は変えたほうがいい. ex. `num_ways`とか

### 空間計算量がO(1)のやり方

上記で, 各ステップで直前の値しか使っていないので直前の値を変数で保持しておけば良い

- pros: 空間計算量を削減できる
- cons: ループ間で変数を目で追わないといけないので認知負荷がかかる

```py
def numWays(self, n: int, k: int) -> int:
    previous_num_tail_two_same = 0
    previous_num_tail_two_different = k
    for i in range(2, n + 1):
        num_tail_two_different = (k - 1) * (previous_num_tail_two_same + previous_num_tail_two_different)
        num_tail_two_same = previous_num_tail_two_different
        previous_num_tail_two_same = num_tail_two_same
        previous_num_tail_two_different = num_tail_two_different

    return num_tail_two_different + num_tail_two_same
```

- previous*\* => num_tail_two*_, num*tail_two*_ => new\_\*にしたほうがいいかも

**再帰 & `@cache` を使ったトップダウン実装がシンプル**
https://github.com/Fuminiton/LeetCode/pull/30

- pros: ボトムアップ(DPテーブル)より読みやすく、メモ化も自動
- cons: nが大きいと再帰上限に当たる
  時間計算量: O(N) (@cacheをつけなかったら再帰の計算量はO(2\*\*N))
  空間計算量: O(N) cacheにNエントリ + call stack N

```python
from functools import cache

def numWays(self, n: int, k: int) -> int:
    @cache
    def num_ways_helper(n: int):
        if n == 1:
            return k
        if n == 2:
            return k * k
        return (k - 1) * (num_ways_helper(n - 2) + num_ways_helper(n - 1))

    return num_ways_helper(n)
```

!warning
🤖 @cache はキャッシュをクリアしないので、k が異なる呼び出しをすると古いキャッシュが使われる問題があります。num_ways を呼ぶたびに新しい @cache が作られる（ネストしているので）ので今回は問題ありませんが、意識しておくと良いです。

- クラスのメソッドにつけるとまずい

---

### 組み合わせ論的な解き方

    - n個を長さ１か２のブロックに分割する。ブロック数をmとすると, mブロックの分割のパターン数 * 色の選び方（k * (k-1) ** (m-1)）
    - mブロックでnを分割する方法は, 再帰で求められる
    -

- 時間計算量 最悪O(2\*\*N)
- 空間計算量 O(N) コールスタックの深さは最大n

```py
def numWays(self, n: int, k: int) -> int:
    def count_ways_by_blocks(target, m):
        if target == 0:
            return k * (k - 1) ** (m - 1)

        if target < 0:
            return 0

        return count_ways_by_blocks(target - 1, m + 1) + count_ways_by_blocks(target - 2, m + 1)

    return count_ways_by_blocks(n, 0)
```

---

**行列累乗による O(log n) 解法**
https://github.com/naoto-iwase/leetcode/pull/35

> 漸化式を線形変換による行列表現に直し、冪乗法を適用すると、時間計算量がO(n) -> O(log n)になるとのこと

漸化式 $T_i = (k-1)(T_{i-1} + T_{i-2})$ を行列表現に直すと：
$$\begin{bmatrix} T_i \\ T_{i-1} \end{bmatrix} = \begin{bmatrix} k-1 & k-1 \\ 1 & 0 \end{bmatrix}^{n-2} \begin{bmatrix} k^2 \\ k \end{bmatrix}$$
行列累乗を二分累乗法（冪乗法）で O(log n) に落とせる。

---

### コードレビューの観点

**変数名 `count_ways` は動詞？名詞？**
https://github.com/mamo3gr/arai60/pull/57

> `count_ways` だけ見ると `count` を動詞、`ways` を目的語とした関数名と誤認する可能性がある。`ways_count` や `num_ways` が適切。

---

**条件式の主役を先に書く**
https://github.com/Fuminiton/LeetCode/pull/30

```py
 while 2 + loop_count <= n:
```

> 主役を最も優先・主張して書きたい。`if (変数) < (定数):` の形が自然言語的にしっくりくる。

---

### その他

https://github.com/goto-untrapped/Arai60/pull/44/changes/BASE..b0b76df73f7b0b3c15b5ae4aef0066cfe611eb1b#r1703434310

> メタ的な考え方になってしまうのですが、戻り値の型が int のため、戻り値の最大値は 2^31 ≒ 2 _ 10^9 くらいになるとおもいます。再帰回数と戻り値の最大値が等しいと仮定すると、 2^n = 2^31 で、 n=31 となります。 10ns _ 2^31 ≒ 10ns \* 109 = 10s くらいになります。 k の値が 2 以上であれば、 n の値はもっと小さくなります。そのため、約 1 s で返ってきているのだと思います。

int型の制約からnの範囲を仮定して計算時間を見積もっている

---

**LRU Cache の実装: `OrderedDict` vs 自前 Doubly-Linked List**
https://github.com/Fuminiton/LeetCode/pull/30 / https://github.com/goto-untrapped/Arai60/pull/44

> OrderedDict の中身は Doubly-Linked List なので、まあ、練習としては、Doubly-Linked List 自体を書いて欲しい

Python の `OrderedDict` は内部で Doubly-Linked List を使っている（[CPython実装](https://github.com/python/cpython/blob/main/Lib/collections/__init__.py#L89)）。LRU Cache の練習としては自前実装が本質的。

---

**式をまとめるか、展開したままにするか**
https://github.com/Fuminiton/LeetCode/pull/30

```py
# まとめた版
(k - 1) * (prev_prev_ways + prev_ways)

# 展開版
(k - 1) * prev_prev_ways + (k - 1) * prev_ways
```

> 展開版の方が「前の色と違う色で塗るパターンと前の色と同じ色で塗るパターンの和を出している」という意図が伝わりやすい。ただし式をまとめた上でコメントで補足する方法も有効。

### k連続以上不可になったら？

- 状態数がk-1個に増える
- 状態は同じようにDPでテーブルやループ間変数とかで持つ

### DPテーブルとメモ化（@cache）の使い分け

|              | メモ化（@cache）           | DPテーブル             |
| ------------ | -------------------------- | ---------------------- |
| 計算方向     | トップダウン（再帰）       | ボトムアップ（ループ） |
| サブ問題が疎 | ◎ 必要な分だけ計算         | △ 全部計算する         |
| n が大きい   | △ 再帰上限に当たる         | ◎                      |
| 実装の自然さ | ◎ 問題の構造をそのまま表現 | △ 順序を考える必要あり |
| 速度         | △ ハッシュのオーバーヘッド | ◎ 定数倍速い           |
| 空間         | O(n) キャッシュ + スタック | O(n) → O(1) に削減可能 |

Paint Fence は全サブ問題（1〜n）を使うのでDPテーブルが適している。

### 🤖 `lru_cache` 内部実装メモ（CPython: `Lib/functools.py`）

**データ構造**
- `cache = {}` — dict（hashtable）：キーからノードを O(1) で引く
- `root = [root, root, None, None]` — 循環 Doubly-Linked List（番兵ノード）：各ノードは `[prev, next, key, result]` のリスト

**循環リストの構造**
- `root[NEXT]` = 最古（削除対象）
- `root[PREV]` = 最新（新ノードの挿入先）

**キャッシュヒット時**：アクセスされたノードを末尾（最新）に移動
```py
link_prev[NEXT] = link_next   # 切り離し
link_next[PREV] = link_prev
last = root[PREV]
last[NEXT] = root[PREV] = link  # 末尾に挿入
link[PREV] = last
link[NEXT] = root
```

**容量満杯時**：古い `root` に新データを書き込み、最古ノードを新 `root` に昇格
```py
oldroot = root
oldroot[KEY] = key        # 古いrootに新データ書き込み
oldroot[RESULT] = result
root = oldroot[NEXT]      # 最古を新rootに（= 最古を削除）
del cache[oldkey]
cache[key] = oldroot      # oldrootは末尾に残る
```
新ノードを allocate せず既存ノードを再利用する巧妙な設計。

操作のイメージ：
```
操作前:
... ←→ 最新 ←→ oldroot(番兵) ←→ 最古 ←→ ...

操作後:
... ←→ 最新 ←→ oldroot(新データ) ←→ 新root(旧最古、番兵に昇格) ←→ ...
```
古い番兵ノード（root）に新データを書き込むことで末尾データノードに変身させる。`最新[NEXT] = oldroot` のリンクは操作前から存在しているので更新不要。同時に最古ノードを新番兵に昇格させることで、ノードの allocate なしに「末尾挿入 + 最古削除」を同時実現している。

**`@cache` は `lru_cache(maxsize=None)` のラッパー**
- `maxsize=None` のとき Linked List 不使用、dict だけで動く
- 順序管理が不要なので lock も不要（GIL で保護される）

---

### 🤖 C実装との比較（`Modules/_functoolsmodule.c`）

**データ構造の違い**

| | Python実装 | C実装 |
|---|---|---|
| ノード | `[prev, next, key, result]` のリスト | `struct lru_list_elem { prev, next, hash, key, result }` |
| 番兵 | `root = []` (リスト) | `lru_cache_object` 自体が `lru_list_elem root` を内包 |
| hashの保持 | なし（毎回計算） | `hash` フィールドで保持し再計算を回避 |

**C実装のノード定義（L1175）**
```c
typedef struct lru_list_elem {
    PyObject_HEAD
    struct lru_list_elem *prev, *next;  /* borrowed links */
    Py_hash_t hash;
    PyObject *key, *result;
} lru_list_elem;
```

**キャッシュヒット時（L1418）**
```c
lru_cache_extract_link(link);   // 切り離し
lru_cache_append_link(self, link);  // 末尾に追加
```
Python実装と同じ構造だが、関数化されて読みやすい。

**満杯時（L1517）**
```c
link = self->root.next;          // 最古を取得
lru_cache_extract_link(link);    // 切り離し
// dictから削除
link->key = key;                 // ノードを再利用して新データ書き込み
link->result = result;
lru_cache_append_link(self, link);  // 末尾に追加
```
Python実装の「oldroot再利用」と同じ発想だが、C実装は**最古ノードを直接再利用**する（rootを新しい番兵にするトリックは使わない）。

**Python実装との最大の差異**
- Python実装: `root` ノードを再利用して番兵を移動させるトリック
- C実装: 最古ノードを直接再利用し `lru_cache_append_link` で末尾に追加。よりシンプル

---

### 🤖 OrderedDict との比較（`Lib/collections/__init__.py`）

**データ構造**
```python
self.__hardroot = _Link()        # 番兵の実体
self.__root = _proxy(self.__hardroot)  # weakref proxy
self.__map = {}                  # key → Link のマッピング
```

`lru_cache` との違い：`prev` リンクが **weakref proxy** になっている。循環参照を防ぐためで、GCの負担を減らす設計。

weakref とは?

通常の参照は参照カウントを増やすが、weakref は増やさない。オブジェクトが他から参照されなくなったとき GC される。

```python
import weakref
a = SomeObject()      # 参照カウント = 1
b = a                 # 参照カウント = 2
c = weakref.proxy(a)  # 参照カウント = 2のまま（weakrefは増やさない）
del a; del b          # 参照カウント = 0 → GCされる
c.xxx  # → ReferenceError（もう存在しない）
```

**OrderedDict で使う理由**：`prev` を強参照にすると `A.next→B, B.prev→A` の循環参照になりGCされない。`prev` を weakref にすることで循環を断ち切る。
**挿入（`__setitem__`、L119）**
```python
self.__map[key] = link = Link()
root = self.__root
last = root.prev
link.prev, link.next, link.key = last, root, key
last.next = link
root.prev = proxy(link)   # prevはweakref
```

**`move_to_end`（L194）**：LRUのアクセス時移動に相当
```python
link = self.__map[key]
# 切り離し
link_prev.next = link_next
link_next.prev = link_prev
# 末尾に挿入
last.next = link
root.prev = soft_link  # weakref proxyで更新
```

**3者まとめ**

| | Python `lru_cache` | C `lru_cache` | `OrderedDict` |
|---|---|---|---|
| ノード実装 | リスト `[prev,next,key,result]` | struct | `_Link` クラス |
| prev リンク | 直接参照 | ポインタ | weakref proxy |
| hash保持 | なし | あり（最適化） | なし |
| 満杯時再利用 | root を移動するトリック | 最古ノードを直接再利用 | 対象外 |
| スレッドセーフ | `RLock` | Critical Section | なし |


👱 とりあえず書いてみる
```py
class Node:
    def __init__(self, key=None, val=None):
        self.key = key
        self.val = val
        self.prev = None
        self.next = None

  class LRUCache:
    def __init__(self, capacity):
        self.capacity = capacity
        self.cache = {}  # key → Node

        # 番兵ノード（headが最古、tailが最新）
        # head.prev, tail.nextは存在しない
        self.head = Node()
        self.tail = Node()
        self.head.next = self.tail
        self.tail.prev = self.head

    def get(self, key):
        if key not in self.cache:
            return -1

        node = self.cache[key]
        self._move_to_tail(node)
        return node.val

    def put(self, key, val):
        if key in self.cache:
            node = self.cache[key]
            node.val = val
            self._move_to_tail(node)
            return 

        node = Node(key, val)
        self.cache[key] = node
        self._insert_before_tail(node)
        if len(self.cache) > self.capacity:
            self._evict()

    def _insert_before_tail(self, node):
        prev = self.tail.prev
        prev.next = node
        node.prev = prev
        node.next = self.tail
        self.tail.prev = node

    def _remove(self, node):
        node.prev.next = node.next
        node.next.prev = node.prev

    def _move_to_tail(self, node):
        self._remove(node)
        self._insert_before_tail(node)

    def _evict(self):
        oldest = self.head.next  # 最古
        self._remove(oldest)
        del self.cache[oldest.key]
```
## Step3

2つのDPテーブルを使う解法がしっくり来たので練習

```py
def numWays(self, n: int, k: int) -> int:
    num_two_tails_different = [0] * (n + 1)
    num_two_tails_same = [0] * (n + 1)

    num_two_tails_same[1] = 0
    num_two_tails_different[1] = k
    for i in range(2, n + 1):
        num_two_tails_different[i] = (k - 1) * (num_two_tails_different[i - 1] + num_two_tails_same[i - 1])
        num_two_tails_same[i] = num_two_tails_different[i - 1]
    
    return num_two_tails_same[n] + num_two_tails_different[n]
```