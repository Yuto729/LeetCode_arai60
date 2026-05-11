# Search in Rotated Sorted Array
There is an integer array nums sorted in ascending order (with distinct values).
Prior to being passed to your function, nums is possibly **left rotated** at an unknown index k (1 <= k < nums.length) such that the resulting array is [nums[k], nums[k+1], ..., nums[n-1], nums[0], nums[1], ..., nums[k-1]] (0-indexed). For example, [0,1,2,4,5,6,7] might be left rotated by 3 indices and become [4,5,6,7,0,1,2].

Given the array nums after the possible rotation and an integer target, return the index of target if it is in nums, or -1 if it is not in nums.
You must write an algorithm with O(log n) runtime complexity.

Example 1:
Input: nums = [4,5,6,7,0,1,2], target = 0
Output: 4

Example
Input: nums = [4,5,6,7,0,1,2], target = 1
Output: 5

Example 2:
Input: nums = [4,5,6,7,0,1,2], target = 3
Output: -1

Example 3:
Input: nums = [1], target = 0
Output: -1

Example:
Input: nums = [1,2,3,4,5], target = 1
Ouput: 0

Constraints:
- 1 <= nums.length <= 5000
- -10^4 <= nums[i] <= 10^4
- All values of nums are unique.
- nums is an ascending array that is possibly rotated.
- -10^4 <= target <= 10^4

Approach
- 前問のように境界を探す -> どちら側にtargetが入っているかがすぐにわかるのでそこで二分探索
    - 上記のやり方で解けるが、ここでは1回のループで解くことを目標にする

- 時間をかけて考えて、以下のようになることがわかった
    1. midがどちらのsort済み配列にあるか（前提：境界を境に２つの単調増加列が繋がっている）
    2. targetはどちらの配列にあるか、とnums[mid]とtargetの比較をする

ただ、途中まで書いたが正解できなさそうなのでヒントをもらった
40mくらい
```py
class Solution:
    def search(self, nums: List[int], target: int) -> int:
        left, right = 0, len(nums)
        while left < right:
            mid = (left + right) // 2
            if nums[mid] < nums[0]:
                # midは右側の配列にある
                if target < nums[0]:
                    # targetも右の配列の中にある
                    if nums[mid] < target:
                        left = mid + 1
                        continue
                    
                    right = mid
                    continue
                
                # targetは左がわ
                right = mid
                continue
            
            # midは左の配列の中にある
            if target < nums[0]:
                # targetは右の配列の中にある
                left = mid + 1
                continue
            
            # targetも左側にある
            if nums[mid] < target:
                left = mid + 1
                continue
            
            right = mid
        if left == len(nums):
            if nums[0] == target:
                return 0
            
            return -1
            
        if nums[left] == target:
            return left

        return -1
```
🤖
- 最後の特殊処理はこんな感じで簡単に書ける書ける
```py
if left < len(nums) and nums[left] == target:
    return left

if nums[0] == target:
    return 0

return -1
```
- 上記の解答の不変条件は？
    - leftより左 -> targetと違う側にあるか、nums[i] < target
    - right以降 -> targetと違う側にあるか、nums[i] >= target
    -> 述語にすると、「targetと同じ側かつnums[i] < target」
最初のFalseの位置を探すプログラムになる。
left == rightの時、その位置はtargetと違う側にいるか、nums[i] == targetとなる最初の位置となるので、最後に等しいかどうかの確認が必要になる

## Step2 他の人のコード・コメントを読む

主な解き方
- 2回2分探索(境界探索 -> 通常探索)
- 1回ループ
- bisect_left + key関数

### priority関数によるbisect_left一発解法
[Yoshiki-Iwasa#36](https://github.com/Yoshiki-Iwasa/Arai60/pull/36#discussion_r1712955053) → https://github.com/Yoshiki-Iwasa/Arai60/pull/36#discussion_r1712955053
> これ、後ろ単に x でいいですね。(x <= nums[-1], x)

bisect_leftの`ke`yとは、今まで自分で考えてた「述語」にあたるものだが、True/Falseとは限らない。
key関数を `(x <= nums[-1], x)` というタプルにすることで、rotationをほどいた順序を復元し、bisect_leftを1回で済ませる。
- 第1キー: `x <= nums[-1]` → False(=0, 左側)が先、True(=1, 右側)が後 → rotation前の順序が復元
- 第2キー: `x` そのもの → 同じ側の中での大小比較
- `(nums[-1] >= x, cmp(x, target))` → `(x <= nums[-1], target <= x)` → 最終的に `(x <= nums[-1], x)` へと簡略化

難しいのであくまで参考に留めておく
```py
import bisect                                                        

class Solution:                                                      
    def search(self, nums: List[int], target: int) -> int:           
        def key(x):                                                  
            return (x <= nums[-1], x)                              
                                                                    
        index = bisect.bisect_left(nums, key(target), key=key)       
        if index < len(nums) and nums[index] == target:
            return index                                             
        return -1
```

### 図を書いて考える
[fhiyo → Yoshiki-Iwasa#36](https://github.com/Yoshiki-Iwasa/Arai60/pull/36#discussion_r1699530429)
> 図を書いてみるといいかもしれません。

斜めの2本の線でrotated sorted arrayを可視化する。midとtargetがどちら側にあるかの場合分けが視覚的に理解できる

### nums[-1]を基準にした1回ループ解法
[skypenguins#29](https://github.com/skypenguins/coding-practice/pull/29#discussion_r2558434093)
> 自分なら下記のように書きます。

```py
# 不変条件：
# - leftより左はrotationエリアが違うか、targetより小さい
# - rightより右はrotationエリアが違うか、target以上
while left <= right:
    mid = (left + right) // 2
    if nums[mid] > nums[-1] and target <= nums[-1]:
        left = mid + 1
        continue
    if nums[mid] <= nums[-1] and target > nums[-1]:
        right = mid - 1
        continue
    # 同じ側 → 通常の二分探索
    if nums[mid] < target:
        left = mid + 1
    else:
        right = mid - 1
```
nums[-1]を基準にすると、midとtargetの「側」判定が対称的に書ける

自分の回答についても同じように条件をフラットにしてみた
```py
class Solution:
    def search(self, nums: List[int], target: int) -> int:
        left, right = 0, len(nums)
        while left < right:
            mid = (left + right) // 2
            # leftより左側がtargetと異なるエリアである
            if nums[mid] >= nums[0] and target < nums[0]:
                left = mid + 1
                continue
            
            # right以降がtargetと異なるエリアである
            if nums[mid] < nums[0] and target >= nums[0]:
                right = mid
                continue
            
            # leftより左側はtargetより小さい
            if nums[mid] < target:
                left = mid + 1
                continue
            
            # right以降はtarget以上
            right = mid

        if left < len(nums) and nums[left] == target:             
            return left

        if nums[0] == target:                                        
            return 0                                               

        return -1
```

### early returnの`nums[mid] == target`
[Yoshiki-Iwasa#36](https://github.com/Yoshiki-Iwasa/Arai60/pull/36#discussion_r2112655430)
> `if nums[mid] == target {` があるためたまたま動いてしまっているように見えました。この if 文なしで同様のコードが書けますか？

閉区間（`right = mid - 1`）では、`target == nums[mid]`のときmidを`left = mid + 1`で飛び越すか`right = mid - 1`で除外するかしかない。どちらもmidを区間から失うので、early returnが必須。半開区間（`right = mid`）ならmidが区間に残るのでearly return不要

### 不変条件の明文化
[garunitule#43](https://github.com/garunitule/coding_practice/pull/43) → [oda コメント](https://github.com/garunitule/coding_practice/pull/43#discussion_r2161764070)
> left は left 以下のものはすべて最小ではないことが確定したもの。right は、right よりも右のものはすべて最小ではないことが確定したもの

不変条件を書くことで、等号・不等号ガチャを避けられる。「leftとrightの不変条件がこんがらがる」という悩みは、不変条件を先に決めてから実装する（top-down）ことで解消


## Step3
整理すると、この問題は以下の４つのケースに場合分けできる
- midが左側・targetが右側 -> 自明にtargetはmidより右側
- midが右側・targetが左側 -> 自明にtargetはmidより左側
- 同じ側かつ, nums[mid] < target -> targetはmidより右側
- 同じ側かつ, nums[mid] >= target -> targetはmid以左

=> 述語：「targetと同じ側にいて、かつnums[i] < target」
不変条件
- leftより左：targetと違うエリア or nums[i] < target (i < left)
- right以降：targetと違うエリアか or nums[i] >= target (i >= right)
left = rightに収束した時の位置は、「述語がFalseになる最初の位置」= 「targetと同じエリアかつ、target以上となる最初の位置、またはtargetと違うエリア」

```py
class Solution:
    def search(self, nums: List[int], target: int) -> int:
        left, right = 0, len(nums)
        while left < right:
            mid = (left + right) // 2
            if nums[mid] < nums[0] and target >= nums[0]:
                right = mid
                continue

            if nums[mid] >= nums[0] and target < nums[0]:
                left = mid + 1
                continue
            
            if nums[mid] < target:
                left = mid + 1
                continue

            right = mid
        
        if left < len(nums) and nums[left] == target:
            return left
        
        if nums[0] == target:
            return 0
        
        return -1
```