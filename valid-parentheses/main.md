## Step1

これは前に一度解いたことがあってスタックを用いるということは覚えていた.
とりあえずスタックを用いるということを頼りに実装. Acceptされたものが以下.

```py
class Solution:
    def isValid(self, s: str) -> bool:
        open_branckets = deque()
        def is_close_brancket(s):
            return s in ['}', ']', ')']

        def are_branckets_pair(open, close):
            pair_dict = {
                '}': '{',
                ')': '(',
                ']': '['
            }
            if pair_dict[close] == open:
                return True

            return False

        if len(s) <= 1:
            return False

        for s in s:
            if is_close_brancket(s):
                if len(open_branckets) == 0:
                    return False

                top_open_brancket = open_branckets.pop()
                if not are_branckets_pair(top_open_brancket, s):
                    return False
            else:
                open_branckets.append(s)

        if len(open_branckets) == 0:
            return True

        return False
```

<https://leetcode.com/problems/valid-parentheses/solutions/7358823/video-2-ways-to-solve-this-question-by-n-hwp6/>
以上を参考にして整える. close brancketかどうかの判定とbrancketがペアかどうかはどちらも一つのDictを使えば事足りる.
変数の命名なども改善.

```py
class Solution:
    def isValid(self, s: str) -> bool:
        open_branckets = deque()
        open_to_close = {
            '(': ')',
            '{': '}',
            '[': ']'
        }

        for char in s:
            if char in open_to_close.keys():
                open_branckets.append(char)

            elif char in open_to_close.values():
                if not open_branckets or open_to_close[open_branckets.pop()] != char:
                    return False
            else:
                raise ValueError("invalid argument.")
        # 以下はまとめて `return not open_branckets`とテクニカルに書けるがちょっとわかりにくい.
        if len(open_branckets) != 0:
            return False

        return True

```

## Step2 他の人のコードを見る

- 豆知識
  <https://github.com/bumbuboon/Leetcode/pull/7/files#diff-d6ab6ab43ae442a1d7f23d67893348a226b06cf4bee29194b31eb5498da4f268R84-R102>
  文脈自由文法とプッシュダウン・オートマトンについて. この問題と結びつけて覚えておきたい.
  文脈自由文法 => 非終端記号が単独で生成規則に従う. 置換は常に記号1つを別の文字列に置き換える（文脈に自由）
  プッシュダウン・オートマトンで書ける.

<https://docs.python.org/ja/3.13/library/queue.html>
<https://github.com/python/cpython/blob/3.13/Lib/queue.py>
LifoQueueクラスというのがあるがマルチスレッド用のwrapperクラスなので今回の問題には適していなさそう.

<https://github.com/bumbuboon/Leetcode/pull/7#discussion_r1810557932>
Dequeは双方向LinkedListを用いているのでListに比べてオーバーヘッドがあるらしい.

- Listを用いて実装し直し＆細かいところを直してみる.

```py
class Solution:
    def isValid(self, s: str) -> bool:
        open_branckets = []
        open_to_close = {
            '(': ')',
            '{': '}',
            '[': ']'
        }

        for char in s:
            if char in open_to_close:
                open_branckets.append(char)
                continue

            # `elif char in open_to_close.values():` ←この条件分岐がなくても正しく動く. charがopen_to_closeになかった場合は以下の2個目の条件でTrueになるため.
            if not open_branckets or open_to_close[open_branckets.pop()] != char:
                    return False

        if len(open_branckets) != 0:
            return False

        return True
```


## Step3
```py
class Solution:
        def isValid(self, s: str) -> bool:
            open_branckets = []
            open_to_close = {
                '(': ')',
                '{': '}',
                '[': ']'
            }

            for char in s:
                if char in open_to_close:
                    open_branckets.append(char)
                    continue

                if not open_branckets or open_to_close[open_branckets.pop()] != char:
                    return False

            return len(open_branckets) == 0

```


## 余談
他の人の解答で挙げられていたDequeやLifoQueueなどのデータ構造がどのような仕組みで実装されているかを一度調べておきたい.
Cpythonの[queue.py](https://github.com/python/cpython/blob/3.13/Lib/queue.py#L40)にあるクラスはマルチスレッド環境で動作させるためのもの.(内部ではmutexと条件変数を用いて制御している.)
キューの実装には`deque`, スタックの実装にはリストを用いているのでデータ構造的にはこれらを使うのと変わらない. 例えば以下のようなプログラムを実行するのに使われる.
in/outのたびにロックを取得したり, pthread_wait(), pthread_broadcast()に相当する操作をしているので多少オーバーヘッドが生じる. 
```py
from queue import Queue
import threading

q = Queue()

def producer():
    for i in range(10):
        q.put(i)
        print('produce', i)
    q.put(None)  # end

def consumer():
    while True:
        item = q.get()
        if item is None:
            break
        print('consume', item)
        q.task_done()

threading.Thread(target=producer).start()
threading.Thread(target=consumer).start()

q.join()

```


Dequeの実装: https://github.com/python/cpython/blob/3.13/Modules/_collectionsmodule.c
DequeはBlockというメモリが連続したオブジェクトを(64個？)まとめて格納するデータ構造を**双方向につなげる**構造を取っている.
Block間ではメモリアドレスが連続していない. １つのBlockが空になったり満杯になったりするとそのたびに古いBlockが解放されたり, 新しいBlockが割り当てられたりするのでListと比べると多少オーバーヘッドが生じるらしい.
また, 今回のような単純な問題に対してオーバースペックかもしれない.


実際にどれくらい差が出るのか比べてみた.
```py
import time
from collections import deque
from queue import LifoQueue

N = 200_000
def bench(title, push, pop):
    # warm-up
    for _ in range(2000):
        push(1)
        pop()

    t0 = time.perf_counter()
    for _ in range(N):
        push(1)
    for _ in range(N):
        pop()
    t1 = time.perf_counter()

    print(f"{title}: {t1 - t0:.6f} sec")


# list stack
lst = []
bench("list (append/pop)", lst.append, lst.pop)

# deque stack
dq = deque()
bench("deque (append/pop)", dq.append, dq.pop)

# LifoQueue stack
q = LifoQueue()
bench("LifoQueue (put/get)", q.put, q.get)
```

結果
```bash
list (append/pop): 0.019174 sec
deque (append/pop): 0.020571 sec
LifoQueue (put/get): 0.418176 sec
```
何回か実行したが, ListのほうがDequeよりほんの少し速く, LifoQueueは明らかに遅かった.
