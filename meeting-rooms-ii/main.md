Given an array of meeting time intervals intervals where intervals[i] = [start_i, end_i], return the minimum number of conference rooms required.

Example 1:
Input: intervals = [[0,30],[5,10],[15,20]]
Output: 2

Example 2:
Input: intervals = [[7,10],[2,4]]
Output: 1

Constraints:
- 1 <= intervals.length <= 10^4
- 0 <= start_i < end_i <= 10^6


## Step1
最大で同時に何ルームが占有されるかを求めれば良い。前問の解き方と基本的には同じ

例でどのように求めるかのイメージ
- 時間軸に区間を書く
0  5  10  15  20  30
|------------------| ミーティングA [0,30)
   |---|             ミーティングB [5,10)
           |---|     ミーティングC [15,20)

- 同時に何本走ってるか数えてみる
0  5  10  15  20  30
|------------------| ミーティングA [0,30)
   |---|             ミーティングB [5,10)
           |---|     ミーティングC [15,20)
↑  ↑    ↑  ↑    ↑   
1  2    1  2    1    同時進行数

同時進行数は区間の端でしか変化していないので、区間の両端だけ見れば良い。区間の始まりと終わりをバラして時系列順の「イベント」として並べ、始まりイベントで+1, 終わりイベントで-1すると同時進行数が逐次的にもとまる。最大の進行数が答えになる

Time: O(nlogn)
Space: O(n)
```py
class Solution:
    def minMeetingRooms(self, intervals: List[List[int]]) -> int:
        events = []
        for start, end in intervals:
            events.append((start, +1))
            events.append((end, -1))
        
        events.sort()
        num_used_rooms = 0
        max_required_rooms = 0
        for _, room_demand in events:
            num_used_rooms += room_demand
            max_required_rooms = max(max_required_rooms, num_used_rooms)
        
        return max_required_rooms
```

他の解法
- min heap
- start / endソート

Min-heap解法
発想：「今この瞬間いくつの部屋が使われているか」を以下のように数えることができそう

各部屋の黒板にその部屋を使っているミーティングの終了時刻が書いてある。
[部屋1: 終了10時] [部屋2: 終了20時] [部屋3: 終了30時]
新しいミーティング [12,25]がきたとすると、新しい部屋が必要か？ -> どれかの部屋が開始時刻の12時までに空いていれば、その部屋を使える。
-> 一番早く空く部屋を見て、それが12時以降であれば新しい部屋が必要になる。新しい部屋を用意し、黒板に新たな終了時刻を書く。空いていれば、その部屋を使い回すが、黒板の終了時刻を消し新しい終了時刻を書く操作をする

「一番早く空く部屋」はどのように管理できるか？ -> heapを使えば管理できそう

アルゴリズムに落とし込む：
- heapには最初のミーティングの終了時刻を入れておく
- intervalsを走査し、開始時刻がheapの先頭の終了時刻より早い時、必要な部屋の数をインクリメントする
    - 遅いときはインクリメントしない O(n) & heapをpopする
- 各intervalの終了時刻をheapに追加する O(logn)

Time: O(nlogn)
Space: O(n)
```py
class Solution:
    def minMeetingRooms(self, intervals: List[List[int]]) -> int:
        sorted_intervals = sorted(intervals, key=lambda x: x[0])
        heap = [sorted_intervals[0][1]]
        num_required_rooms = 1
        for s, e in sorted_intervals[1:]:
            if s >= heap[0]:
                # 先頭のミーティングは終了するのでpop
                heapq.heappop(heap)
            else:
                num_required_rooms += 1

            heapq.heappush(heap, e)
        
        return num_required_rooms
```

🤖
- heapに最初に値を入れる必要はない
- heapは以下の意味を持っている
    - 使用中の部屋たちの終了時刻
    - サイズ：過去の最大同時数
    - 最小値：次に空く部屋の終了時刻
num_required_roomsをカウントせずとも、heapの長さが答えとなる
- heapの変数名は上記も踏まえて, `active_rooms`とかがいいかも
```py
class Solution:
    def minMeetingRooms(self, intervals: List[List[int]]) -> int:
        sorted_intervals = sorted(intervals, key=lambda x: x[0])
        active_rooms = []
        for s, e in sorted_intervals:
            if active_rooms and s >= active_rooms[0]:
                # 先頭のミーティングは終了するのでpop
                heapq.heappop(active_rooms)

            heapq.heappush(active_rooms, e)
        
        return len(active_rooms)
```


## Step2

### Two-pointers解法: start/end を別ソートしてマージ
[mamo3gr#60](https://github.com/mamo3gr/arai60/pull/60) `step2_two_pointers.py` / [naoto-iwase#57](https://github.com/naoto-iwase/leetcode/pull/57) 実装4
```py
starts = sorted(i.start for i in intervals)
ends = sorted(i.end for i in intervals)
e = 0
num_rooms = 0
min_rooms = 0
for start in starts:
    num_rooms += 1
    while e < len(ends) and ends[e] <= start:
        e += 1
        num_rooms -= 1
    min_rooms = max(min_rooms, num_rooms)
return min_rooms
```
sweep lineと等価だが2ポインタで実装。「すべての開始イベントを処理し終えたら、もう部屋を追加することはない」という終了条件が綺麗。Time O(n log n), Space O(n)。マージソートのマージステップに似た雰囲気。

### `bisect_right` で「最も遅く空く部屋」を選ぶ別の貪欲法
[naoto-iwase#57](https://github.com/naoto-iwase/leetcode/pull/57) 実装1, 2
```py
ordered_intervals = sorted(intervals, key=lambda x: x.end)
rooms_end = []   # ソート済み: 各部屋の最終終了時刻
for interval in ordered_intervals:
    room_to_reserve = bisect.bisect_right(rooms_end, interval.start) - 1
    if room_to_reserve >= 0:
        rooms_end.pop(room_to_reserve)
    rooms_end.append(interval.end)
return len(rooms_end)
```
終了時刻でソートし、各 `interval.start` に対して「それ以下の終了時刻を持つ部屋」を二分探索で発見。heap版（最も早く空く部屋を狙う）とは**逆向きの貪欲**。「ソートキー × 取りに行く方向」の組み合わせで複数の正解があるのが貪欲問題の面白さ。

### 座標圧縮ヘルパーを切り出すと綺麗
[mamo3gr#60](https://github.com/mamo3gr/arai60/pull/60)
```py
def coordinate_compression(coordinate: list[int]) -> dict[int, int]:
    coordinate = sorted(set(coordinate))
    return {value: i for i, value in enumerate(coordinate)}
```
汎用的なユーティリティとして覚えておく価値あり。imos法と組み合わせると `O(T)` → `O(n)` に空間が落ちる。

### 同時刻の `+1/-1` を dict で group by して曖昧さを排除
[mamo3gr#60](https://github.com/mamo3gr/arai60/pull/60) `step3.py`
```py
time_to_demand = collections.defaultdict(int)
for meeting in intervals:
    time_to_demand[meeting.start] += 1
    time_to_demand[meeting.end] -= 1

total_demand = 0
min_rooms = 0
for _, demand in sorted(time_to_demand.items()):
    total_demand += demand
    min_rooms = max(min_rooms, total_demand)
return min_rooms
```
`(time, +1)` / `(time, -1)` のタプル順序パズル（"-1 を先に処理しないと半開区間が壊れる"）を回避できる。同時刻のイベントは**同じキーで自然に相殺**。**コードを読まなくても半開区間の意味が自明**になる。

### 変数名: `active_rooms` / `num_active_rooms`（瞬間値のニュアンス）
[olsen-blue#57](https://github.com/olsen-blue/Arai60/pull/57#discussion_r2027474114)
> 変数名でやりたいことが汲み取れると嬉しいです。active_roomsとかどうでしょうか。

`num_rooms_needed` よりも `num_active_rooms` のほうが「**今この瞬間**進行中の値」と読める。`active` の語感が瞬間値のニュアンスを担保する。

### 変数名: コメントの内容を変数名に取り込む
[naoto-iwase#57](https://github.com/naoto-iwase/leetcode/pull/57)
> もう少しコメントの内容を反映させた変数名にした方が間違えにくいと思いました。starts -> start_times, i -> start_index のような感じです。

`starts` だけだと「開始時刻のリスト」とは限らない。`start_times` まで踏み込むと型と意味が両方伝わる。`i` も用途が明確なら `start_index` のように具体名にするほうが読みやすい。

### 浮動小数点なら imos 法（固定配列）は破綻する
[olsen-blue#57](https://github.com/olsen-blue/Arai60/pull/57#discussion_r2027474114)
> 解法の取りうる範囲の数字を全部挙げはじめたら結構驚くと思うんですよね。浮動小数点だったらこのままでは駄目ですよね。

`MAX_RANGE = 10**6` の配列を確保する解法は、**整数で値域が小さい**という前提に強く依存。値域が大きい/連続的な値の場合は座標圧縮 or sweep line が必須。「制約に頼った解法は制約が変わると壊れる」

### Heap解法はリアルタイム / Cloud Run の Auto-scaling っぽい
[olsen-blue#57](https://github.com/olsen-blue/Arai60/pull/57)
> ヒープの解法だと、「全体の会議室のリソース管理者が時系列順で処理をする」というリアルタイムのイメージが持てて、この血の通った感じが良いと思いました。会議室の追加の挙動は、Cloud Run のスケーリングと非常に似ていると感じました。

heap解法 = オートスケーラ。「リクエスト（=ミーティング）が来たら、空きインスタンス（=部屋）が無ければ新規起動、あれば使い回す」と対応。

### パズル感（暗黙のルールに依存したコード）の警戒
[Ryotaro25#61](https://github.com/Ryotaro25/leetcode_first60/pull/61#discussion_r2005183830)
> end, start がこの辞書順であることを利用していることに気がつけというのは、結構パズルを作っていると思います。

`(time, "start")` vs `(time, "end")` のタプル比較で `"end" < "start"` が成り立つ、というアルファベット順の偶然に依存した実装は**読み手に推理を要求するパズルコード**。コードレビューで「気づきの負荷が高い箇所」を指摘するのは重要な観点。

---

## Step3
```py
class Solution:
    def minMeetingRooms(self, intervals: List[List[int]]) -> int:
        events = []
        for s, e in intervals:
            events.append((s, +1))
            events.append((e, -1))
        
        events.sort()
        active_rooms = 0
        min_required_rooms = 0
        for _, room_demand in events:
            active_rooms += room_demand
            min_required_rooms = max(min_required_rooms, active_rooms)
        
        return min_required_rooms
```


### 余談: Pythonの`int`はなぜ28バイトもあるのか
mamo3grさんのPRでメモリ見積もりに `28 bytes/int` と書かれていて気になったので調べた。  
ref: https://medium.com/@abhishek.ec/why-does-an-integer-take-28-bytes-in-python-and-only-4-bytes-in-c-d09192d73f2e

CのintはCPUが扱える生のビット列（32bit = 4 bytes）。一方Pythonの`int`は**オブジェクト**であり、数値以外に以下のメタデータを持つ:

| フィールド | サイズ | 役割 |
|---|---|---|
| `ob_refcnt` | 8 bytes | 参照カウント（GC用） |
| `ob_type` | 8 bytes | 型オブジェクトへのポインタ（動的型付けのため） |
| `ob_size` | 8 bytes | 桁数（任意精度整数のため、符号付き） |
| `ob_digit` | 4 bytes〜 | 実際の数値データ（可変長） |

合計 **8 + 8 + 8 + 4 = 28 bytes**（小さい整数の場合）。

なぜこのオーバーヘッドが必要か:
- **参照カウントGC** → `ob_refcnt`
- **動的型付け / `type(x)` / メソッド解決** → `ob_type`
- **任意精度整数** (`10**1000` も扱える) → `ob_size` + 可変長 `ob_digit`

Cの`int`は「ビット列」、Pythonの`int`は「ビット列を持ったオブジェクト」。Pythonの柔軟さはこの24バイトの「オブジェクト税」の上に成り立っている。

数値計算でメモリを節約したいときは:
- `array` モジュール（型固定、要素4 or 8 bytes）
- NumPy（`np.int32` で4 bytes/要素、ベクトル演算もC実装で高速）

なお `[0] * 10**6` のような場合、CPythonは小さな整数（-5〜256）をキャッシュして使い回すので、実際は「ポインタ8 bytes × 10^6 + 共有intオブジェクト1個」で約8MB。それでもCの`int[10^6]` (4MB)の倍。