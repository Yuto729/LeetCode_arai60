## Step1
ナイーブにそれぞれの数を数えたハッシュマップを作成したあと, valueをkeyにしてソートし, keyを上からk個取る.
時間計算量: O(n + m logm + k). 3msくらいかかった.いろんな解法をあとで試してわかるが, 組み込みの`sorted`関数は普通に安定して速い.
```py
class Solution:
    def topKFrequent(self, nums: List[int], k: int) -> List[int]:
        number_to_count = {}
        for num in nums:
            if num in number_to_count:
                number_to_count[num] += 1
                continue
            
            number_to_count[num] = 1
        
        sorted_number_to_count = dict(sorted(number_to_count.items(), reverse=True, key=lambda item: item[1]))
        numbers_sorted_by_count = list(sorted_number_to_count.keys())
        return [numbers_sorted_by_count[i] for i in range(k)]
```
https://github.com/fuga-98/arai60/pull/10#discussion_r1967591652
sortedを使う部分で冗長になってしまっていたので上記を参考に簡略化. sortedの内部では引数のイテレーターが作成される.
dictのイテレーター（つまり`__iter__`メソッドで実装されているもの）はdictのキーの列である. そして`key(elem) for elem in [dictのキーの列]`というような形で, key引数が使われので以下のように書けば簡単になる.
```diff
--- sorted_number_to_count = dict(sorted(number_to_count.items(), reverse=True, key=lambda item: item[1]))
+++ numbers_sorted_by_count = sorted(number_to_count, reverse=True, key=number_to_count.get)

```

## Step2
https://github.com/docto-rin/leetcode/pull/9/

上からk番目までということはk番目以降は並び替える必要がない. 上からk個を全体を並び替えずに都合よく取り出せるデータ構造 => 優先度付きキュー
frequencyとnumをセットにしたものをfrequencyをキーにしてmax heapを構成する. そしてそこからtop k個を取り出せばいい.
ユニークな要素数をmとして, 計算量はO(n + m logm + k logm)になる. 最悪計算量はすべてがユニークのときでO(n logn).
上記の回答では, frequencyにマイナスをかけることで最小ヒープでできるようにしている.
https://docs.python.org/3/library/heapq.html#basic-examples
pythonのheapqでは, tupleの第一要素がキーになるっぽい.

Step1の解法と速度は変わらない.
```py
class Solution:
    def topKFrequent(self, nums: List[int], k: int) -> List[int]:
        number_to_frequency = {}
        heap = []
        for num in nums:
            if num in number_to_frequency:
                number_to_frequency[num] += 1
                continue
            
            number_to_frequency[num] = 1
        
        for number, frequency in number_to_frequency.items():
            heapq.heappush(heap, (-frequency, number))
        
        top_k_frequent_elements = []
        for _ in range(k):
            top_k_frequent_elements.append(heapq.heappop(heap)[1])
        
        return top_k_frequent_elements
```

Dictをそのままで最小heapにできないか？
https://docs.python.org/3/library/heapq.html
上記を見ると, `heapify`はlistを引数に取るので無理そうだが, nlargestであればiterableを引数に取れるのでdictでもいけそう.
上からk番目までを取ればいい. 以下の実装で6msくらい.
```py
class Solution:
    def topKFrequent(self, nums: List[int], k: int) -> List[int]:
        number_to_frequency = {}
        heap = []
        for num in nums:
            if num in number_to_frequency:
                number_to_frequency[num] += 1
                continue
            
            number_to_frequency[num] = 1

        # `key=number_to_frequency.get`でも良い
        top_k_frequent_elements = heapq.nlargest(k, number_to_frequency, key=lambda key: number_to_frequency[key])
        
        return top_k_frequent_elements

```
nlargestの計算量は, 求める個数をn, iterableのサイズをNとするとO(N log n)となる.よって、上記のアルゴリズムの計算量は, O(n + m log k)となる.
nlargestの内部実装がどうなっているかを見てみる.
- iterableオブジェクトとして受け取ったものをイテレーターに変換し, 最初のn個を用いてサイズnのヒープを作る.
- 残りの要素について,最小ヒープの最小値と比較してそれより大きければ置き換えるという操作を繰り替えす.
```py
def nlargest(n, iterable, key=None):
    # 略 

    it = iter(iterable)
    result = [(key(elem), i, elem) for i, elem in zip(range(0, -n, -1), it)]
    if not result:
        return result
    heapify(result)
    top = result[0][0]
    order = -n
    _heapreplace = heapreplace
    for elem in it:
        k = key(elem)
        if top < k:
            # popして新しい値を追加する
            _heapreplace(result, (k, order, elem))
            top, _order, _elem = result[0]
            order -= 1
    result.sort(reverse=True)
    return [elem for (k, order, elem) in result]
```
以下のように書くとnlargestと同じことをしていることになる.
- heapの大きさがkより大きくなったら, frequencyが最小の要素を削除する.
```py
class Solution:
    def topKFrequent(self, nums: List[int], k: int) -> List[int]:
        number_to_frequency = {}
        heap = []
        for num in nums:
            number_to_frequency[num] = number_to_frequency.get(num, 0) + 1
        
        for num, freq in number_to_frequency.items():
            heapq.heappush(heap, (freq, num))
            if len(heap) > k:
                heapq.heappop(heap)
        
        return [num for _, num in heap]
```

計算量は改善してるはずだがRuntimeはあまり変わらないのはどれも最悪計算量がO(n logn)で, テストケースの中に最悪ケースがあるからだと思われる.
最悪計算量がO(n logn)未満になるようにしたい.
バケットソートが使えるっぽいので実装してみる.
- 各要素の頻度は 0 ~ n個なので, n+1の長さの配列を用意し,各インデックスを頻度としてnumを追加する.
- 頻度の高い方（bucketの後ろ）から要素を抜いてきてk個になったら終了
計算量はO(n)になったはずだが, Runtimeは長くなった.(だいたい7 ~ 11msくらい)

- m, kが小さい時は, mlogkやmlogmなどがnより小さくなりうる
- サイズnの配列を用意するのが重い.
- forループの過程で,大量の空リスト`[]`を走査するが, それぞれが独立したオブジェクトなのでランダムなメモリに配置され, キャッシュ効率が悪くなる.
などの理由が考えられそう.

```py
class Solution:
    def topKFrequent(self, nums: List[int], k: int) -> List[int]:
        number_to_frequency = {}
        for num in nums:
            number_to_frequency[num] = number_to_frequency.get(num, 0) + 1
        
        # frequencyをindexとしてnumを入れる.
        bucket = [[] for _ in range(len(nums) + 1)]
        for num, freq in number_to_frequency.items():
            bucket[freq].append(num)
        
        top_k_frequent_elements = []
        
        for count in range(len(bucket) - 1, 0, -1):
            for num in bucket[count]:
                top_k_frequent_elements.append(num)
                if len(top_k_frequent_elements) == k:
                    return top_k_frequent_elements

        return top_k_frequenct_elements
```
https://github.com/potrue/leetcode/pull/9#discussion_r2083523591
以上を参考に, bucketの初期化部分を以下のように変更したところ3ms程度まで短縮できた.
```diff
--- bucket = [[] for _ in range(len(nums) + 1)]
# bucketの長さをmに
+++ bucket = [[] for _ in range(max(number_to_frequency.values()) + 1)] 
```

## Step3
```py
class Solution:
    def topKFrequent(self, nums: List[int], k: int) -> List[int]:
        number_to_frequency = {}
        heap = []
        for num in nums:
            number_to_frequency[num] = number_to_frequency.get(num, 0) + 1
        
        for num, freq in number_to_frequency.items():
            heapq.heappush(heap, (freq, num))
            if len(heap) > k:
                heapq.heappop(heap)
        
        return [num for _, num in heap]
```