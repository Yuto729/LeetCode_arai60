Given an array of meeting time intervals where intervals[i] = [start_i, end_i], determine if a person could attend all meetings.

Example 1:
Input: intervals = [[0,30],[5,10],[15,20]]
Output: false

Example 2:
Input: intervals = [[7,10],[2,4]]
Output: true

Constraints:
- 0 <= intervals.length <= 10^4
- intervals[i].length == 2
- 0 <= starti < endi <= 10^6

## Step1
各intervalが重なってなければok. 重なっていたらだめということか？

わからなかったので教えてもらった
すべてのミーティングに参加できる -> 任意の２つの区間A, Bが重ならない。 では、A, Bが重なるとは？-> 後に始まった方が先に始まった方の終了より前に始まるということ。
つまり、「先に始まった方」「後に始まった方」という順序を決めたい。そこで開始時刻をキーとして昇順にソートする。
次に、隣り合うミーティングを順に見ていき、前のミーティングの終了時刻 > 次のミーティングの開始時刻なら重なっているのでFalse。最後まで重なりがなければTrueとする。

Q. なぜ隣だけで十分か？ 
-> 開始時刻でソートした後、i < j のとき start[i] ≤ start[j] が保証される。
もし i と j が重なる（end[i] > start[j]）なら、間にある i+1 についても:
- start[i+1] ≤ start[j] なので end[i] > start[j] ≥ start[i+1]
- → i と i+1 も重なっている

Time: O(nlogn)
Space: O(1)
```py
class Solution:
    def canAttendMeetings(self, intervals: List[List[int]]) -> bool:
        sorted_intervals = sorted(intervals, key=lambda x: x[0])
        for i in range(1, len(intervals)):
            if sorted_intervals[i - 1][1] > sorted_intervals[i][0]:
                return False
        
        return True
```

他の解法
- ソートを使わない方法。0 <= start < end <= 10^6で有限であるので、時間軸を配列とみなして、各時刻に何個のミーティングが存在するか数えるという方針。

ナイーブな実装。計算量はO(n * T)で今回の制約では最大 10^10 なのでTLEになると思ったがAcceptした。
ただ計算量は改善したい。
```py
class Solution:
    def canAttendMeetings(self, intervals: List[List[int]]) -> bool:
        num_meetings_at = [0] * (10 ** 6)
        for interval in intervals:
            for t in range(interval[0], interval[1]):
                if num_meetings_at[t] > 0:
                    return False

                num_meetings_at[t] += 1
        
        return True
```
上記の改善
🤖
> 各時刻tについてインクリメントする部分が無駄になっている。各区間の両端でのミーティング数の増減を記録して、最後に累積和を取ることで各時刻の同時ミーティング数がもとまる。
imos法と呼ばれているらしい

Time: O(n + T)
Space: O(T)

トレードオフ
- nが小さくTが大きい今回の制約では、ソートした方がベター
- nが巨大で、Tが小さいときであればこの方法が役にたつ
```py
class Solution:                                                        
    def canAttendMeetings(self, intervals: List[List[int]]) -> bool:
        T = 10 ** 6 + 1
        # diff[t] = 時刻tで起きるミーティング数の変化量
        diff = [0] * (T + 1)
        for s, e in intervals:
            diff[s] += 1
            diff[e] -= 1   # e時点では終わっている（半開区間）

        count = 0
        for v in diff:
            # 累積和 = この瞬間に進行中のミーティング数
            count += v
            if count > 1:
                return False
        return True
```
シミュレート
ex. intervals = [[0,30],[5,10],[15,20]]
1. 
diffを時刻0 ~ 30まで用意する。初期値は0
diff配列の結果
時刻:   0  5 10 15 20 30
diff: +1 +1 -1  +1 -1 -1

2. 累積和をとる
t = 0 ~ 4 -> 1
t = 5 ~ 9 -> 2
t = 10 ~ 14 -> 1
t = 15 ~ 19 -> 2
t = 20 ~ 29 -> 1
t = 30 -> 0

上記を見ると、t=5でミーティングがバッティングしているので答えはFalse


- Sweep Lineアルゴリズム
imos法とは異なり、時間軸全体を走らず、イベント（ミーティングの開始/終了）が起きる点のみを見る。Tが大きく、nが小さい時に有利
Time: O(nlogn) Space: O(n)
```py
class Solution:                                                        
    def canAttendMeetings(self, intervals: List[List[int]]) -> bool:
        events = []
        for start, end in intervals:
            events.append((start, +1))
            events.append((end, -1))
        
        # 同時刻なら-1（終了）を先に処理する -> 半開区間 [s, e)として扱う
        # -1が先じゃないと、ケースによっては間違える。ex. [[10,20],[20,30]]
        events.sort(key=lambda x: (x[0], x[1]))
        count = 0
        for _, delta in events:
            count += delta
            if count > 1:
                return False

        return True
```

## Step2

### itertools.pairwise で隣接ペアを綺麗に書く
[mamo3gr#59](https://github.com/mamo3gr/arai60/pull/59)
> 隣接する要素をインデックスで取りに行っているが、`itertools` に同様の処理がありそう。-> あった。
> https://docs.python.org/3/library/itertools.html#itertools.pairwise
```py
for a, b in itertools.pairwise(intervals_sorted):
    if a.end > b.start:
        return False
```
`range(1, len(...))` でインデックスを回すよりも意図が明確で、オフバイワン系のミスも防げる。Python 3.10+ で利用可。

### 累積和の解法は「座標圧縮」で空間を圧縮できる
[olsen-blue#56](https://github.com/olsen-blue/Arai60/pull/56#discussion_r2023904388)
> 座標圧縮みたいなことをする手はありますね。

座標圧縮とは、数列が与えられてた時、それぞれの要素が「全体の中で何番目に小さいか」を求めていく作業のこと

差分配列は `T = 10^6` 分のメモリを取るが、実際に変化が起きるのは `2n` 点だけ。出てくる時刻だけを集めてランクに振り直せば、空間を `O(T)` から `O(n)` に落とせる。tom4649さんの `sol2.py` がまさにこの実装

```py
class Solution:                                                        
    def canAttendMeetings(self, intervals: List[List[int]]) -> bool:
        all_times_set = set()
        # 出てくる時刻を全部集めてソート & 重複除去する
        for s, e in intervals:
            all_times_set.add(s)
            all_times_set.add(e)
        all_times = sorted(all_times_set) # sorted()はiterableな入力に対して常にlistを返す. refs: https://docs.python.org/3/library/functions.html#sorted

        # 値: ランクの辞書を作成する
        time_to_rank = {t: i for i, t in enumerate(all_times)}
        # 圧縮された空間でimos法
        diff = [0] * len(all_times)
        for s, e in intervals:
            diff[time_to_rank[s]] += 1
            diff[time_to_rank[e]] -= 1
        
        count = 0
        for d in diff:
            count += d
            if count > 1:
                return False
        
        return True
```
これは結局 sweep line と等価になる（イベント時刻だけ見るので）。差分配列の動作は変化が起きるのは両端だけで間を累積和で埋めているので、変化が起きない区間はいくら長くても累積和の判定結果は変わらず、今回の問題では間を潰しても同じ。「重なりがあるか」「最大同時数は」のような順序にしか依存しないときはこれで十分

### 入力配列を破壊しない
[dxxsxsxkx#55 (mamo3gr)](https://github.com/dxxsxsxkx/leetcode/pull/55#discussion_r2999081423)
> `sorted.cpp` では受け取った `intervals` を並び替えてしまっていますが、ここのようにコピーして使うのが良いと思いました。実際はそもそも、引数を `const` にして守ってあげるのが良さそうですね。

`intervals.sort()` (in-place) ではなく `sorted(intervals, ...)` を使う。Pythonでも引数の不変性は重要で、呼び出し側が「渡した配列がソートされている」前提を持つと思わぬバグを生む。

### `__lt__` を後付けで生やすトリック
[Satorien#54](https://github.com/Satorien/LeetCode/pull/54#discussion_r2660585823)
> 無理やり `__lt__` を実装できるの面白いですね。heapify を使うと in-place に置き換えられるので注意が必要だなと思いました。

`heapq` は要素同士の `<` 比較を要求するので、Intervalオブジェクトを直接ヒープに入れたい場合は比較関数を生やす必要がある。Pythonでは外側から `Interval.__lt__ = lambda self, other: self.start < other.start` のようにmonkey-patchできる。

### 変数名: `prefix_sum` より `room` などドメイン語彙
[olsen-blue#56](https://github.com/olsen-blue/Arai60/pull/56#discussion_r2003903637) / [dxxsxsxkx#55](https://github.com/dxxsxsxkx/leetcode/pull/55#discussion_r2999111794)
> `prefix_sum` でも伝わると思いましたが、部屋(会議室、鍵)などのような変数名にするかコメントがあってもいいかなと思いました。
> `room` という抽象化もできますね。私はこちらの方がしっくりきました。

`prefix_sum` はアルゴリズム上の概念名
`active_meetings` や `rooms_in_use` のようなドメイン語の方が良い
- 自分のコードだと、`count` -> `active_meetings`

### イベントを heap で管理する解法
[mamo3gr#59](https://github.com/mamo3gr/arai60/pull/59) `step2_events_by_heap.py`
```py
@dataclasses.dataclass
class Event:
    time: int
    room_demand: int
    def __lt__(self, other):
        return (self.time, self.room_demand) < (other.time, other.room_demand)
```
ヒープを使うと「動的にイベントが追加される」シナリオに拡張しやすい。

---

## Step3
```py
class Solution:                                                        
    def canAttendMeetings(self, intervals: List[List[int]]) -> bool:
        sorted_intervals = sorted(intervals, key=lambda x: x[0])
        for i in range(1, len(sorted_intervals)):
            if sorted_intervals[i - 1][1] > sorted_intervals[i][0]:
                return False
        
        return True
```

Event版
- room_demand -> 「部屋を１つ要求する」/ 「部屋を１つ解放する」
- rooms_in_use
Q.同時刻に始まるのと終わるmtgが存在するのがNGのときは？ -> eventsのソートで、+1を先にする

```py
class Solution:                                                        
    def canAttendMeetings(self, intervals: List[List[int]]) -> bool:
        events = []
        for s, e in intervals:
            events.append((s, 1))
            events.append((e, -1))
        
        # (時刻, diff) 順にソート, -1(終わるのが先になる)
        events.sort()
        rooms_in_use = 0
        for _, room_demand in events:
            rooms_in_use += room_demand
            if rooms_in_use > 1:
                return False
        
        return True
```

### 類題
- [253. Meeting Rooms II](https://leetcode.com/problems/meeting-rooms-ii/)
- [56. Merge Intervals](https://leetcode.com/problems/merge-intervals/)
- [57. Insert Interval](https://leetcode.com/problems/insert-interval/)
- [435. Non-overlapping Intervals](https://leetcode.com/problems/non-overlapping-intervals/)
- [729. My Calendar I](https://leetcode.com/problems/my-calendar-i/)
- [731. My Calendar II](https://leetcode.com/problems/my-calendar-ii/)
- [732. My Calendar III](https://leetcode.com/problems/my-calendar-iii/)
- [1851. Minimum Interval to Include Each Query](https://leetcode.com/problems/minimum-interval-to-include-each-query/)
