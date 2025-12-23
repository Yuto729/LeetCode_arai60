## Step1
素朴なアプローチとしてiから始まってjで終わるsubarrayの合計を計算するやり方がある. このとき、nums[j]には負の値も含まれるので, 途中でbreakすることができない.
計算量O(n^2)
```py
class Solution:
    def subarraySum(self, nums: List[int], k: int) -> int:
        count = 0
        total = 0
        for i in range(len(nums)):
            total = 0
            for j in range(i, len(nums)):
                total += nums[j]
                if total == k:
                    count += 1

        return count
```
以上のプログラムだとTLEになる.
二重ループを一重ループにしたいのでそのためにループ間で何の情報を保持したら良いかを考える. 
iから始まるsubarrayで, `sum(nums[j:i])`の値がkになるjを探していると理解する. 
累積和（ヒントを見た）を使うと, sum(nums[j:i]) = cumsum[i] - cumsum[j]になる. iを用いてjを特定するには, i, kが与えられているときにcumsum[j] = cumsum[i] - kとなるjを探す問題になるが,配列は負の値も含むためcumsum[j]は複数ある可能性がある. 累積和をkey, その累積和の出現回数をvalueとする辞書を用いる.

答えを見ながら以下のように書いた.
```py
class Solution:
    def subarraySum(self, nums: List[int], k: int) -> int:
        count = 0
        total = 0
        cumsum_to_freq = defaultdict(int)
        cumsum_to_freq[0] = 1
        for num in nums:
            total += num
            if total - k in cumsum_to_freq:
                count += cumsum_to_freq[total - k]

            cumsum_to_freq[total] += 1
        
        return count
```
こう書くとif文を省略可
```diff
--- if total - k in cumsum_to_freq:
---     count += cumsum_to_freq[total - k]
+++ count += cumsum_to_freq.get(total - k, 0) 
```
- 累積和を先にメモしておく方法もある.（空間計算量が増加）

## Step2 他の人のコード・コメントを見る
https://discord.com/channels/1084280443945353267/1183683738635346001/1192145962479665304
例えを用いて問題を理解する.

「山登りの標高」
山道を歩き,標高差がちょうどkメートルになるような区間を探す.（数を数える問題から区間を列挙する問題に置き換え）
- スタート地点の標高は0メートル
- 歩くたびに標高が増減する（numsの値だけ増減. つまりnumsは各地点間の標高差を表している）
- 標高差がちょうどkメートルになるような区間を列挙する

これを解くには, 歩きながら「各標高を通ったときの地点」を記録するメモ係が必要. メモの最初には標高0メートルの欄がある.
区間の見つけ方：
現在の標高が 10m で、標高差 k = 7m の区間を探したいとき => 標高3mの地点があるかをメモ係に問い合わせ, その時の地点をスタートとして区間とする.

### フォローアップ・発展をちょっと考えてみる
- 合計がk以下の部分配列を求める => 今回のアルゴリズムだと難しい.
    - 配列の要素がすべて正の整数（例のケースだとだんだん山が高くなるケース） => 時間: O(n), 空間: O(1)で解ける.
    - 解法はスライディングウィンドウ&two pointer（観測者を2人用意）
こんな感じ
```py
def countSubarrays(nums, k):
    count = 0
    total = 0
    left = 0
    
    for right in range(len(nums)):
        total += nums[right]
        while total > k and left <= right:
            total -= nums[left]
            left += 1
        # [left, right] の範囲内のすべての部分配列が条件を満たす
        count += right - left + 1
    
    return count
```

## Step3
```py


```