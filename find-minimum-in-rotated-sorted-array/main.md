Suppose an array of length n sorted in ascending order is rotated between 1 and n times. For example, the array nums = [0,1,2,4,5,6,7] might become:

- [4,5,6,7,0,1,2] if it was rotated 4 times.
- [0,1,2,4,5,6,7] if it was rotated 7 times.
Notice that rotating an array [a[0], a[1], a[2], ..., a[n-1]] 1 time results in the array [a[n-1], a[0], a[1], a[2], ..., a[n-2]].

Given the sorted rotated array nums of unique elements, return the minimum element of this array.
You must write an algorithm that runs in O(log n) time.

Example 1:
Input: nums = [3,4,5,1,2]
Output: 1
Explanation: The original array was [1,2,3,4,5] rotated 3 times.

Example 2:
Input: nums = [4,5,6,7,0,1,2]
Output: 0
Explanation: The original array was [0,1,2,4,5,6,7] and it was rotated 4 times.

Example 3:
Input: nums = [11,13,15,17]
Output: 11
Explanation: The original array was [11,13,15,17] and it was rotated 4 times. 

Example 4:
Input: nums = [0,1,-3,-2]
Output: -3

Constraints:
- n == nums.length
- 1 <= n <= 5000
- -5000 <= nums[i] <= 5000
- All the integers of nums are unique.
- nums is sorted and rotated between 1 and n times.


Approach
- ローテーションした配列には、途中で単調増加から切り替わる境目があるのでそこを見つければ良い
- ローテーションの回数kに対して、配列の先頭の値は単調減少する(回転数が1以上)
ここまではわかったがあと少し発想が足りなかったのでヒントをもらう
> または、配列の任意の位置`mid`で切り取った時、左半分と右半分のどちらかはソート済みという性質から、`nums[mid]`と何を比較すれば、最小値がどちら側にあるか判定できるか？
-> numsの先頭と比較すれば良さそう。先頭より小さい時は、最小値は左にあり、大きい時は右にあるはず。

筋道をちゃんと立てると以下のようになる

回転ソート配列では、ある境界を挟んで、
- 前半: `nums[0]`以上の要素
- 後半: `nums[0]`未満の要素
という性質が成り立つので、以下のように述語を定義する。
述語: `nums[i] < nums[0]`
上記に対して、例えば [4,5,6,7,0,1,2] -> [F,F,F,F,T,T,T]と単調になるので二分探索が使える。
- 求めたいもの -> 最初のTの位置 = bisect_leftの対象
半開区間`[left, right)`とすると、
- 左の不変条件: leftより左は全てF -> `nums[i] > nums[0]`
- 右の不変条件: right以降は全てT -> `nums[i] < nums[0]`
初期値は、不変条件が空集合で自明に成り立つ値を設定する。
- 半開区間の部分は、T/Fが**未確定領域**

```py
class Solution:
    def findMin(self, nums: List[int]) -> int:
        left, right = 0, len(nums)
        while left < right:
            mid = (left + right) // 2
            if nums[mid] < nums[0]:
                right = mid
                continue
            
            left = mid + 1
        
        if left == len(nums):
            # ローテーションが0回の時だけインデックスがオーバーするので例外
            return nums[0]
        
        return nums[left]
```
- 閉区間の実装
```py
class Solution:
    def findMin(self, nums: List[int]) -> int:
        left, right = 0, len(nums) - 1
        while left <= right:
            mid = (left + right) // 2
            if nums[mid] < nums[0]:
                right = mid - 1
                continue
            
            left = mid + 1
        
        if left == len(nums):
            return nums[0]
        
        return nums[left]
```
🤖
- `nums[-1]`と比較するようにすれば最後の処理が要らなくなる。
    - `left`が`nums[-1]`以下で最左のインデックスになるので、必ず配列の範囲内に収まる
```py
def findMin(self, nums: List[int]) -> int:
    left, right = 0, len(nums)
    while left < right:
        mid = (left + right) // 2
        if nums[mid] <= nums[-1]:
            right = mid
            continue
        
        left = mid + 1
    
    return nums[left]
```
follow up
- 重複要素がある場合 -> 上記の述語だと解決不能
    - 線形探索でやるしかない？
- 最小値ではなく特定のターゲットを探す場合は？
- target = 0のインデックスを返す -> 境界を特定した後にそれぞれの単調増加列で二分探索
    - -> 
- 回転回数は求められるか？ -> 最小値のインデックスがそのままkになる。

## Step2

### 開区間で両端と比較するアプローチ
[naoto-iwase#25](https://github.com/naoto-iwase/leetcode/pull/25) 実装1
```py
class Solution:
    def findMin(self, nums: List[int]) -> int:
        first = 0
        last = len(nums) - 1
        if nums[first] <= nums[last]:
            return nums[first]
        
        left = first
        right = last
        while right - left > 1:
            mid = (left + right) // 2
            if nums[mid] >= nums[first]:
                left = mid
                continue
            if nums[mid] <= nums[last]:
                right = mid
                continue
        return nums[right]
```
開区間(left, right)で、leftは「nums[first]以上の最大インデックス」、rightは「nums[last]以下の最小インデックス」。回転なしのケースは先にearly returnで弾く必要がある。述語を片方に統一せず両端と比較する

### nums[0] vs nums[-1]: 比較対象の選択が設計を決める
[naoto-iwase#25](https://github.com/naoto-iwase/leetcode/pull/25) / [garunitule#42](https://github.com/garunitule/coding_practice/pull/42#discussion_r2633207600)
> nums[-1]と比較すると、`if nums[0] <= nums[-1]: return nums[0]` の2行を書かずに済みます。

nums[0]と比較すると、回転なし（全要素F）のとき`left`が配列外に出るため特別処理が必要。nums[-1]と比較すると回転なしでも全要素Tとなり、first Trueが`nums[0]`を正しく指す。述語の選び方が設計の複雑さを決める。

### bisect_leftのkey引数 (Python 3.10+)
[naoto-iwase#25](https://github.com/naoto-iwase/leetcode/pull/25)
> Python 3.10よりbisect_leftにはkey引数があり、lambdaを渡せる。

```py
bisect.bisect_left(nums, True, key=lambda x: x <= nums[-1])
```
keyは配列要素にのみ適用され検索値には適用しないため、検索値はTrueが適切（PythonではFalse < True = 0 < 1）。bisect_left/bisect_right × nums[0]/nums[-1]の4パターン全て動く。

### early returnはむしろ遅くなる
[oda](https://github.com/seal-azarashi/leetcode/pull/39#discussion_r1849053009) (seal-azarashi#39)
> 純粋に答えがどこにあるかが均一な分布だったとしましょう。（中略）平均で1ですかね? 一方でループを回すたびに分岐がつくので極限を取るとこの仕組みがあったほうが遅いように見えます。

while内で`nums[left] <= nums[right]`をチェックして早期returnするパターン。平均で1回分の反復しか削減できない一方、毎ループに分岐が追加されるため、理論上は遅くなる。

### 変数名は実態を表せ: target問題
[oda](https://github.com/takuya576/leetcode/pull/2#discussion_r2100783218) (takuya576#2)
> これは「ターゲット」とはいい難いですね。（中略）名前が実態を表していないのが、一番妙なところかと思います。

targetに「閾値」と「これまでの最小値」という2つの役割を持たせていた。変数名は不変条件と対応すべきで、意味が異なるなら別の名前にするか、設計を変えてleft/rightに答えを持たせる方が明快。

### ループは仕事の引き継ぎ
[oda](https://github.com/takuya576/leetcode/pull/2#discussion_r2100997553) (takuya576#2)
> ループはある種の仕事の引き継ぎのようなもので、どういうものだと思って引き継いでいるのか、それが変数名などで初めて読んだ人にもある程度通じるのか、を意識して書くといいでしょう。

### 返り値に使う方の不変条件を先に書く
[nanae772](https://github.com/naoto-iwase/leetcode/pull/25#discussion_r1855810024) (naoto-iwase#25)
> 私は最後に返したほうの不変条件を分かりやすくするために、最後に返す方を先に書くのですがこれは好みかもしれません。

### 二分探索を3つに分解する
[philip82148](https://github.com/takuya576/leetcode/pull/2#discussion_r2098853558) (takuya576#2)
> 1. 条件式のアルゴリズム
> 2. 棒を縮めていくアルゴリズム(+最終的に何を答えにするか)
> 3. エッジケースをどうするか

1が最も重要で、2はパターンが限られ、3はおまけ。述語（単調性）を決めれば残りは導出できる

### 目的→手段→粒度の順で思考する
[nodchip](https://github.com/seal-azarashi/leetcode/pull/39#discussion_r1851404872) (seal-azarashi#39)
> 目的を設定し、目的に必要な手段を決め、手段を粒度の大きい部分から小さい部分に向かって検討していく、という思考ができていないように感じました。

二分探索に限らず、トップダウンで設計する姿勢。「何を探すか（述語）→ どう探すか（区間型）→ 細部（初期値、更新式）」の順序。

## Step3
```py

```