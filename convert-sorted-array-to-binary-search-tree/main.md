## Step1

再帰的にサブツリーを構成していけば良いと考えた。サブツリーの具体的な構成方法について
配列の中央値を根とすれば良い。
時間計算量: O(N) => 各要素が1回ずつ処理されるので -> あってる？
空間計算量: O(N) => numsの部分コピーの合計 = N + N/2 + N/4 + ...（logN個の要素）

```py
class Solution:
    def sortedArrayToBST(self, nums: List[int]) -> Optional[TreeNode]:

        def construct_bintree(nums):
            if len(nums) == 1:
                return TreeNode(nums[0])

            if len(nums) == 0:
                return None

            mid = len(nums) // 2
            root = TreeNode(nums[mid])
            left = nums[:mid]
            right = nums[mid+1:]
            root.left = construct_bintree(left)
            root.right = construct_bintree(right)
            return root

        root = construct_bintree(nums)
        return root
```

`if len(nums) == 1`はいらないっぽい

## Step2

- https://github.com/irohafternoon/LeetCode/pull/28/changes#r2061089474
>この問題だとHelperを使わない再帰の書き方もありますね。そのほうがコンパクトになり、またtotalに関する議論もなくなるので個人的には好きですが、他の問題ではHelperを使ったほうが見通し良いものもあるので、単なる好みの範疇かもしれません。

- https://github.com/colorbox/leetcode/pull/38/changes#r1939019777
> vectorをコピー生成を行っているので、indexで管理するのもありかと思いました。

毎回numsの半分がコピーされているので無駄がある。インデックスを渡すことで効率化することができそう

```py
class Solution:
    def sortedArrayToBST(self, nums: List[int]) -> Optional[TreeNode]:
        def construct_bintree(left_idx, right_idx):
            if left_idx > right_idx:
                return None

            mid_idx = (left_idx + right_idx) // 2
            root = TreeNode(nums[mid_idx])
            root.left = construct_bintree(left_idx, mid_idx - 1)
            root.right = construct_bintree(mid_idx + 1, right_idx)
            return root
        
        root = construct_bintree(0, len(nums) - 1)
        return root
```
または
半開区間での実装
```py
class Solution:
    def sortedArrayToBST(self, nums: List[int]) -> Optional[TreeNode]:

        def construct_bintree(left_idx, right_idx):
            if left_idx >= right_idx:
                return None

            mid_idx = (left_idx + right_idx) // 2
            root = TreeNode(nums[mid_idx])
            root.left = construct_bintree(left_idx, mid_idx)
            root.right = construct_bintree(mid_idx + 1, right_idx)
            return root
        
        root = construct_bintree(0, len(nums))
        return root
```
- https://github.com/colorbox/leetcode/pull/38/
stackで実装をしている。再帰が深くなりすぎるとスタックオーバーフローが起きる（Pythonはデフォルト深さ1000でオーバー）
逐次的にサブツリーを構成するには、- 親ノード - 親ノードの左と右の子要素をスタックに積んでいけばいい
子要素は上記のインデックスを用いた実装と同じ方法で得ることができそう（nums[mid]を使う）

pythonではポインタを持てないので、親ノードのどちらの子に接続するかの情報をスタックで保持しないといけないが２つの方法がある
1. is_left_childフラグ
2. "left" or "right"をスタックに積み、setattrでparentに適用する

1の実装
```py
class Solution:
    def sortedArrayToBST(self, nums: List[int]) -> Optional[TreeNode]:
        if not nums:
            return None

        dummy = TreeNode()
        stack = [(dummy, True, 0, len(nums))]
        while stack:
            parent, is_left_child, left_idx, right_idx = stack.pop()
            if left_idx >= right_idx:
                continue

            mid_idx = (left_idx + right_idx) // 2
            node = TreeNode(nums[mid_idx])
            
            if is_left_child:
                parent.left = node
            else:
                parent.right = node
            stack.append((node, False, mid_idx + 1, right_idx))
            stack.append((node, True, left_idx, mid_idx))

        return dummy.left
```
2の実装
```py
class Solution:
    def sortedArrayToBST(self, nums: List[int]) -> Optional[TreeNode]:
        if not nums:
            return None

        dummy = TreeNode()
        stack = [(dummy, 'left', 0, len(nums))]
        while stack:
            parent, attr, left_idx, right_idx = stack.pop()
            if left_idx >= right_idx:
                continue

            mid_idx = (left_idx + right_idx) // 2
            node = TreeNode(nums[mid_idx])
            
            setattr(parent, attr, node)
            stack.append((node, 'right', mid_idx + 1, right_idx))
            stack.append((node, 'left', left_idx, mid_idx))

        return dummy.left
```


## Step3
スタックで解く
```py
class Solution:
    def sortedArrayToBST(self, nums: List[int]) -> Optional[TreeNode]:
        if not nums:
            return None

        dummy = TreeNode()
        stack = [(dummy, 'left', 0, len(nums))]
        while stack:
            parent, attr, left_idx, right_idx = stack.pop()
            if left_idx >= right_idx:
                continue

            mid_idx = (left_idx + right_idx) // 2
            node = TreeNode(nums[mid_idx])
            
            setattr(parent, attr, node)
            stack.append((node, 'right', mid_idx + 1, right_idx))
            stack.append((node, 'left', left_idx, mid_idx))

        return dummy.left
```