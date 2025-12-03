## Step1
ナイーブな解法. valが追加されるたびにソートをする. 計算量は,毎回のソートにnlogn, `add`が呼び出される回数をmとするとO(m*nlogn). m, nともに最大が10^4なので, だいたい10^9のオーダー.
一度通るかやってみる.
```py
class KthLargest:

    def __init__(self, k: int, nums: List[int]):
        self.k = k
        self.nums = sorted(nums, reverse=True)

    def add(self, val: int) -> int:
        new_sorted_nums = sorted(self.nums + [val], reverse=True)
        self.nums = new_sorted_nums
        return new_sorted_nums[self.k - 1]
```
Acceptしたが, 3082msもかかっている.
ほとんどの解答は9msくらいなので1/1000にしないといけない. O(nlogn)くらいで書ければそれくらいになりそう. `add`に対して線形に時間がかかるのはしょうがないので`add`関数内での順序の更新がO(logn)ならok.
=> 最初から降順に並べているので, 更新は2分探索でやってみる.

1431ms. 1/2くらいになった. listへのinsertの計算時間を考慮し忘れていた. 計算量はO((n + logn) * m)になり, ナイーブな解法と比べて数倍くらいは差が出る計算になるのでだいたい正しい. 

```py
class KthLargest:

    def __init__(self, k: int, nums: List[int]):
        self.k = k
        self.nums = sorted(nums, reverse=True)

    def bin_search(self, val):
        # valが入るindexを変えす.
        left = 0
        right = len(self.nums) - 1
        while left <= right:
            mid = (left + right) // 2
            if val < self.nums[mid]:
                left = mid + 1
            
            elif val == self.nums[mid]:
                return mid
            
            else:
                right = mid - 1
        
        return left
            
    def add(self, val: int) -> int:
        # 2分探索で位置を更新.
        index_to_insert = self.bin_search(val)
        self.nums = self.nums[:index_to_insert] + [val] + self.nums[index_to_insert: ]
        return self.nums[self.k - 1]
```
Q. insert処理と合わせてO(logn)になるにはどうしたらいいか
A. 2分探索木や優先度付きキューなどを使う.

優先度付きキュー（heapq）を用いたら解けそうだとわかったが途中で詰まってしまったので, 以下を参考にして書いてみる.

- 初期化のときに`nums`を*minヒープ*にし, 上位 k 個を選んで保持しておく.
- valが追加されるたびに`heapq.heappush()`で順序を更新する.
- 優先度付きキューの一番上の値を返却.
https://github.com/docto-rin/leetcode/pull/8

速度が100倍くらいになった.
```py
class KthLargest:

    def __init__(self, k: int, nums: List[int]):
        self.k = k
        self.nums = nums
        # minヒープを構成.
        heapq.heapify(self.nums)
        # 長さがkになるまで小さいものからpopしていく.
        self._reduce_heapq_length_below_k()

    def _reduce_heapq_length_below_k(self):
        """
        heapqの長さがkより大きいときにk以下まで減らすメソッド
        """
        if len(self.nums) <= self.k:
            return

        while len(self.nums) > self.k:
                heapq.heappop(self.nums)
        
    def add(self, val: int) -> int:   
        heapq.heappush(self.nums, val)
        # heapqの長さがkより大きい場合小さいものから順に削除
        if len(self.nums) > self.k:
            self._reduce_heapq_length_below_k()
        
        return self.nums[0]
```


## Step2
https://github.com/SanakoMeine/leetcode/pull/10#discussion_r1925053909
`nums`のままよりも`top_k_values`とかのほうが確かに良さそう.

https://github.com/SanakoMeine/leetcode/pull/10/files#r1925028680
`bisect.insort`というのがある. これは2個目の自分のやり方と同じっぽい.

```py
class KthLargest:

    def __init__(self, k: int, nums: List[int]):
        self.k = k
        self.top_k_values = nums
        heapq.heapify(self.top_k_values)
        self._reduce_heapq_length_below_k()

    def _reduce_heapq_length_below_k(self):
        """
        heapqの長さがkより大きいときにk以下まで減らすメソッド
        """
        if len(self.top_k_values) <= self.k:
            return

        while len(self.top_k_values) > self.k:
                heapq.heappop(self.top_k_values)
        
    def add(self, val: int) -> int:   
        heapq.heappush(self.top_k_values, val)
        if len(self.top_k_values) > self.k:
            self._reduce_heapq_length_below_k()
        
        return self.top_k_values[0]

```

## Step3
```py
class KthLargest:

    def __init__(self, k: int, nums: List[int]):
        self.top_k_values = nums
        self.k = k
        heapq.heapify(self.top_k_values)
        self._reduce_heapq_length_below_k()
    
    def _reduce_heapq_length_below_k(self):
        if len(self.top_k_values) <= self.k:
            return
        
        while len(self.top_k_values) > self.k:
            heapq.heappop(self.top_k_values)
    
    def add(self, val: int) -> int:   
        heapq.heappush(self.top_k_values, val)
        self._reduce_heapq_length_below_k()
        
        return self.top_k_values[0]

```

### 余談
* 自前ヒープの実装
https://discord.com/channels/1084280443945353267/1192736784354918470/1194613857046503444

* heapqの実装をみておく
https://github.com/python/cpython/blob/3.14/Lib/heapq.py

- sift down: 要素を追加したときにする操作. スタート位置から木を上にたどり, 親ノードより子ノードの値のほうが小さい場合, 親ノードと子ノードの位置を交換していく操作. 子ノード > 親ノードになるまで続ける.
- sift up: 要素を取り出したときにする操作. スタート位置（pos）からから木を下にたどり, 小さい方の子を引き上げていき, その後 pos の位置にあったノードを適切な位置まで上方向に戻す.(sift dowmを使う)

```py
def heapify(x):
    """Transform list into a heap, in-place, in O(len(x)) time."""
    n = len(x)
    # リストをヒープにするアルゴリズム. sift upの対象は子を持つノード, つまりn//2までのノード.
    # _siftupでiを根とした部分木をヒープ化している. 
    # _siftupでは, iの位置にあるノードを葉の位置に下ろす過程で小さい方の子を引き上げていく. 最後にiの位置にあったノードを適切な位置に上方向に戻す. 
    # 上記の操作の結果, 根（iの位置）には最小値が格納され, 各ノードが子ノードより小さいか等しくなる.
    # bottom upで部分木を最小ヒープにしているので, iの子以下は最小ヒープになっておりiの位置を適切にするだけでよくなっている.
    # 計算量: O(n).
    for i in reversed(range(n//2)):
        _siftup(x, i)
```
```py
def _siftdown(heap, startpos, pos):
    newitem = heap[pos]
    # Follow the path to the root, moving parents down until finding a place
    # newitem fits.
    while pos > startpos:
        parentpos = (pos - 1) >> 1
        parent = heap[parentpos]
        if newitem < parent:
            heap[pos] = parent
            pos = parentpos
            continue
        break
    heap[pos] = newitem

```
```py
def _siftup(heap, pos):
    endpos = len(heap)
    startpos = pos
    newitem = heap[pos]
    # Bubble up the smaller child until hitting a leaf.
    childpos = 2*pos + 1    # leftmost child position
    while childpos < endpos:
        # Set childpos to index of smaller child.
        rightpos = childpos + 1
        if rightpos < endpos and not heap[childpos] < heap[rightpos]:
            childpos = rightpos
        # Move the smaller child up.
        heap[pos] = heap[childpos]
        pos = childpos
        childpos = 2*pos + 1
    # The leaf at pos is empty now.  Put newitem there, and bubble it up
    # to its final resting place (by sifting its parents down).
    heap[pos] = newitem
    _siftdown(heap, startpos, pos)

```
