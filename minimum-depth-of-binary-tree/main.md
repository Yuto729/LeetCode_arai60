## Step1
max depth of binary treeと逆でdepthの最小値を求める問題. ノードの探索方向はdepthが大きくなる方向に探索しているので, 毎回のループでmin_depthを更新すると正しい答えにならない.
子がないノードにあたったときに深さの最小値を更新することにする

時間計算量: O(N), 空間計算量: O(N)
```py
class Solution:
    def minDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0
        
        node_depth_pairs = [(root, 1)]
        min_depth = float('inf')
        while node_depth_pairs:
            node, depth = node_depth_pairs.pop()
            if node.left is None and node.right is None:
                min_depth = min(min_depth, depth)
                continue

            if node.left is not None:
                node_depth_pairs.append((node.left, depth + 1))
            if node.right is not None:
                node_depth_pairs.append((node.right, depth + 1))
        
        return min_depth
```
Runtimeのヒストグラムの最頻値と比較して50倍ほど遅いので明らかに計算量が大きそう.
よく考えてみると最短経路を求める問題っぽいのでBFSで考えることにする. さらに同じ階層ごとに探索をすることを考えるとearly returnできるので高速化できそう.
- frontiersとnext_frontiersを分けることで, 異なる階層のノードが同じキューに入らないようにする
- （論理的にはありえないが）returnせずにwhileループを抜けたときに処理が何もないのは気持ちが悪いと思ったので一応入れておいた

```py
class Solution:
    def minDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0
        
        frontiers = [root]
        depth = 0
        while frontiers:
            next_frontiers = []
            depth += 1
            for node in frontiers:   
                if node.left is None and node.right is None:
                    return depth

                if node.left is not None:
                    next_frontiers.append(node.left)
                if node.right is not None:
                    next_frontiers.append(node.right)
            frontiers = next_frontiers
        
        raise AssertionError("unreachable")
```
- AssertionErrorを投げる以外に, `assert False, "unreachable"`とする方法もある.

## Step2 他の人のコード・コメントを読む
- https://github.com/sakupan102/arai60-practice/pull/23/changes#r1590804846
- https://github.com/olsen-blue/Arai60/pull/22#discussion_r1925335296
> この depth の更新は while の一番下のほうが素直じゃないでしょうか。(つまり、nodes_depth の更新とともに数を増やします。)

depthをインクリメントするタイミングについての話
確かにループの最初でインクリメントするのは違和感がある.

改善後
```py
class Solution:
    def minDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0
        
        frontiers = [root]
        depth = 1
        while frontiers:
            next_frontiers = []
            for node in frontiers:   
                if node.left is None and node.right is None:
                    return depth

                if node.left is not None:
                    next_frontiers.append(node.left)
                if node.right is not None:
                    next_frontiers.append(node.right)
            frontiers = next_frontiers
            depth += 1
        
        raise AssertionError("unreachable")
```

- 再帰で解いてみる
```py
class Solution:
    def minDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0
        
        node = root
        if node.left is None:
            return self.minDepth(node.right) + 1

        if node.right is None:
            return self.minDepth(node.left) + 1
 
        return min(self.minDepth(node.left), self.minDepth(node.right)) + 1
```

## Step3
再帰で練習
```py
class Solution:
    def minDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0
        
        node = root
        if node.left is None and node.right is None:
            return 1
            
        if node.left is None:
            return self.minDepth(node.right) + 1

        if node.right is None:
            return self.minDepth(node.left) + 1
 
        return min(self.minDepth(node.left), self.minDepth(node.right)) + 1
```