## Step1

in: treenode
out: tf
normal
[5,4,8,11,null,13,4,7,2,null,null,null,1], targetSum = 22
edge
- root = []: false
- nodeが一つだけ: targetとイコールか

The number of nodes in the tree is in the range [0, 5000].
-1000 <= Node.val <= 1000
-1000 <= targetSum <= 1000

- solution
DFS, backtrack
rootから探索をしていく。leafに到達したら合計値を見て、targetと比べる。等しくなかったら1歩戻り、別の道にいく
戻る部分は
時間計算量: O(N)最悪全ノードを一回ずつ探索するため

- 再帰
```py
class Solution:
    def hasPathSum(self, root: Optional[TreeNode], targetSum: int) -> bool:
        if not root:
            return False

        def dfs(node, total):
            if node is None:
                return False

            total += node.val
            if node.right is None and node.left is None:
                return total == targetSum

            return dfs(node.right, total) or dfs(node.left, total)
        
        return dfs(root, 0)
```
- スタック版
```py
class Solution:
    def hasPathSum(self, root: Optional[TreeNode], targetSum: int) -> bool:
        if not root:
            return False

        total = 0
        stack = [(root, total)]
        while stack:
            node, total = stack.pop()
            total += node.val
            if node.right is None and node.left is None:
                if total == targetSum:
                    return True

            if node.right is not None:
                stack.append((node.right, total))
            if node.left is not None:
                stack.append((node.left, total))
        
        return False
```
### 改善
- total => path_sum, current_sumのほうが良さそう

### 応用
- 空間計算量はすべてのパスをかえす場合はどうする？
    - スタック, 再帰の引数にいままで通ってきた道を記録する
    1. パスをコピーする場合 => 空間計算量: O(N * H)Hは木の高さ. 各再帰呼出しでO(H)のコピーが発生
    2. 1つのリストをmutateしてbacktrackする方法: O(H)
2のやり方
pathは常にrootから現在のノードまでの道を表す
```py
def pathSum(root, targetSum):
    result = []
    path = []

    def dfs(node, remaining):
        if not node:
            return
        
        path.append(node.val)
        if node.left is None and node.right is None:
            if remaining == node.val:
                # 条件を満たしたら"コピー"をして保存
                result.append(path[:])         
        dfs(node.left, remaining - node.val)
        dfs(node.right, remaining - node.val)

        # post-orderで追加した値を戻してbacktrack
        path.pop()
    
    dfs(root, targetSum)
    return result
```
- 任意の区間の場合（途中から途中もあり）
任意のroot a ~ bまでの和がtargetSum => root ~ root bの和 - root ~ root aの和 = targetSum
=> root aまでの和 - root bまでの和 = targetSum
和がtargetSum - root bまでの和であるようなaを探せばいい(two sumの応用)

## Step2

### レビューコメント
- https://github.com/SuperHotDogCat/coding-interview/pull/37#discussion_r1656055498
> 問題文にbinary tree, The number of nodes in the tree is in the range [0, 5000].とあったので木の高さは深くてもlog_2(n)ぐらいだろうと思いましたが, 片方に偏る場合もテストケースとして考えられるので再帰回数増やすかやめた方が良さそうですね...
    - デフォルトの再帰の深さ(1000)と問題文の制約は考慮したほうがいい

- https://github.com/SuperHotDogCat/coding-interview/pull/37#discussion_r1656050170
> `|`演算子よりかはor演算子の方が良いか。`or`の方がboolを扱う時は馴染みがありそう

- https://docs.python.org/3.12/library/stdtypes.html#boolean-type-bool
> For logical operations, use the boolean operators and, or and not. When applying the bitwise operators &, |, ^ to two booleans, they return a bool equivalent to the logical operations “and”, “or”, “xor”. However, the logical operators and, or and != should be preferred over &, | and ^.

`|`: ビット演算子. 1 | 2 => 3のようにビット演算がされる
`or`: |と異なり短絡評価. つまり左の条件が満たされれば右はチェックしないので効率的
- set演算など => `|`を使おう
- pythonではboolはintのサブクラスなので `|`でも動く

## Step3
```py
class Solution:
    def hasPathSum(self, root: Optional[TreeNode], targetSum: int) -> bool:
        if not root:
            return False
        
        stack = [(root, 0)]
        while stack:
            node, current_sum = stack.pop()
            current_sum += node.val
            if node.left is None and node.right is None:
                if current_sum == targetSum:
                    return True
            
            if node.left is not None:
                stack.append((node.left, current_sum))
            if node.right is not None:
                stack.append((node.right, current_sum))

        return False
```