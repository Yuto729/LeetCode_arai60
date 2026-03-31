## Step1
binary treeが与えられたとき, 最大の深さを計算する問題

Constraints:
- The number of nodes in the tree is in the range [0, 10^4].
- -100 <= Node.val <= 100

シンプルにDFSで解く.
注意点
- エッジケース: rootがNoneのときは0を返す.
```py
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def maxDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0

        max_depth = 1
        stack = [(root, 1)]
        while stack:
            node, depth = stack.pop()
            if node.left is not None:
                stack.append((node.left, depth + 1))
            if node.right is not None:
                stack.append((node.right, depth + 1))
            max_depth = max(max_depth, depth)

        return max_depth
```

- BFS
```py
class Solution:
    def maxDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0

        max_depth = 1
        frontiers = deque()
        frontiers.append((root, 1))
        while frontiers:
            node, depth = frontiers.popleft()
            if node.left is not None:
                frontiers.append((node.left, depth + 1))
            if node.right is not None:
                frontiers.append((node.right, depth + 1))
            max_depth = max(max_depth, depth)

        return max_depth
```

- BFSでレベルごとにカウントする
```py
class Solution:
    def maxDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0

        frontiers = [root]
        depth = 0
        while frontiers:
            depth += 1
            next_frontiers = []
            for node in frontiers:  
                if node.left is not None:
                    next_frontiers.append(node.left)
                if node.right is not None:
                    next_frontiers.append(node.right)
            frontiers = next_frontiers

        return depth
```
## Step2 他の人のコード・コメントなどを読む
- https://github.com/5ky7/arai60/pull/20#discussion_r2615138037
スタックの変数名として, `nodes_with_depth`や`node_and_depths`などが良さそう

再帰でも実装してみる
```py
class Solution:
    def maxDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0
        
        node = root
        max_depth = max(self.maxDepth(node.left), self.maxDepth(node.right)) + 1
        return max_depth
```


## Step3
```py
class Solution:
    def maxDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0
        
        node_depth_pairs = [(root, 1)]
        max_depth = 0
        while node_depth_pairs:
            node, depth = node_depth_pairs.pop()
            max_depth = max(max_depth, depth)
            if node.left is not None:
                node_depth_pairs.append((node.left, depth + 1))
            if node.right is not None:
                node_depth_pairs.append((node.right, depth + 1))

        return max_depth
```
