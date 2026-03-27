## Step1
Given the root of a binary tree, determine if it is a valid binary search tree (BST).
A valid BST is defined as follows:

- The left subtree of a node contains only nodes with keys strictly less than the node's key.
- The right subtree of a node contains only nodes with keys strictly greater than the node's key.
- Both the left and right subtrees must also be binary search trees.

Example
1.
Input: root = [2,1,3]
Output: true

2.
Input: root = [5,1,4,null,null,3,6]
Output: false
Explanation: The root node's value is 5 but its right child's value is 4.

3.
Input: root = [1,1,1]
Output: false

4.
Input: [5, 4, 6, null, null, 3, 7]
Output: false
ノード3はノード6より小さいので左部分木としては正しいが、ルート5より小さいのでBSTとしては不正

Border
Input: root = [1]
Output: True ?

Constraints:

- The number of nodes in the tree is in the range [1, 10^4].
- -2^31 <= Node.val <= 2^31 - 1

Approach
- 再帰
    - node AをルートとしたツリーがBSTである => Aのleft, rightノードをルートとしたツリーがBSTかつA, left, rightがBSTの条件を満たす
    - time complexity: O(N)
    - space: O(H)
上記の方法だと、Example４が解けない
- 再帰のときにupper_limit, lower_limitを渡す
    - rightを探索するときには, node.valが上記範囲に含まれている & node.val以上upper_limit以下に範囲を更新
    - leftを探索するときには, lower_limit以上node.valに更新

- **注意点**
再帰の責務分離（子のチェックを親でやらない）を意識する

```py
class Solution:
    def isValidBST(self, root: Optional[TreeNode]) -> bool:
        if root.left is None and root.right is None:
            return True

        def isValidChildBST(node, upper_limit, lower_limit):
            if not node:
                return True
            
            if node.val <= lower_limit or node.val >= upper_limit:
                return False

            return isValidChildBST(node.left, node.val, lower_limit) and isValidChildBST(node.right, upper_limit, node.val) 
        
        return isValidChildBST(root.left, root.val, -2**31-1) and isValidChildBST(root.right, 2**31, root.val) 
```

AIレビュー
- `upper_limit`, `lower_limit`の引数の順番について、lower, upperの順のほうが読み手が混乱しない
- 最後rootも同じ関数に入れることができる
```py
return isValidChildBST(root, float('-inf'), float('inf')) # node, lower, upper
```

## Step2

lower, upperのデフォルト値に関する議論
https://github.com/nittoco/leetcode/pull/35
- `math.inf`がマジックナンバーっぽい
- `float('inf')`だとnode.valの型(int)と異なるので, 型チェッカーに引っかかる可能性
    - `sys.maxsize`ならintだけど, 厳密な最大値ではないらしい
    https://docs.python.org/ja/3/library/sys.html#sys.maxsize
    > Py_ssize_t 型の変数が取りうる最大値を示す整数です。通常、32 ビットプラットフォームでは 2**31 - 1,64 ビットプラットフォームでは 2**63 - 1 になります

- 結論どちらでも良さそうだが型の一貫性は意識したほうがいいかも

他の解法
1. BFSで、キューに(node, lower, upper)を入れて非再帰で解く
2. 色付きスタックでpre/in/postorderをitterativeに処理
3. in-orderでトラバースしながら、結果が狭義単調増加かどうか調べる

### 上記の解法を非再帰に変換する
```py
class Solution:
    def isValidBST(self, root):
        queue = deque([(float('-inf'), float('inf'), root)])
        while queue:
            lower, upper, node = queue.popleft()
            if node.val <= lower or node.val >= upper:
                return False

            if node.left:
                queue.append((lower, node.val, node.left))
            if node.right:
                queue.append((node.val, upper, node.right))
                
        return True
```
### in-orderの解法

1. 再帰 & generatorを使う
- https://github.com/naoto-iwase/leetcode/pull/33
- https://github.com/nittoco/leetcode/pull/35
generatorを使うべきとき
    - 全部をメモリに溜めなくても１つずつ処理すれば十分なとき（遅延評価でいいとき）
    - 生成と消費を分離したいとき, 今回のようにinorder走査と検証ロジックを別の関心として分けたいとき

- cons: generator生成コスト
- time complexity: O(N)
- space: O(H) Hは木の高さ
```py
class Solution:
    def isValidBST(self, root: Optional[TreeNode]) -> bool:
        def generate_inorder(node):
            if node.left is not None:
                yield from generate_inorder(node.left)
            
            yield node.val
            
            if node.right is not None:
                yield from generate_inorder(node.right)
        
        node_val_generator = generate_inorder(root)
        prev = next(node_val_generator)
        for val in node_val_generator:
            if val <= prev:
                return False
            
            prev = val
        
        return True
```
memo
- `yield from`: 内側のジェネレーターを透過的につなぐシンタックスシュガー
- 🤖AI: inorder_valuesくらいでも伝わります。generatorであることはyieldを見れば分かるので名前に含めなくてもいいです。

2. 再帰 & generatorを使わない
- inorder走査の結果をlistにする => 空間計算量O(N)に増加
- nonlocalで前の値を保持. 走査と判定を分離しない方法
    - pros: 早期リターンができる
    - 空間計算量O(H)
```py
def isValidBST(self, root):
    prev = float('-inf')
    def inorder(node):
        nonlocal prev
        if not node:
            return True
        
        # 左部分木が狭義単調増加になっているかチェック
        if not inorder(node.left):
            return False
        # 自分が狭義単調増加になっているかチェック
        if node.val <= prev:
            return False
        prev = node.val
        # 左部分木と自分のチェックが通ったので, 右のチェックを返り値とする
        return inorder(node.right)
    return inorder(root)
```
3. iterativeな解法
```py
def isValidBST(self, root):
    stack = []
    prev = float('-inf')
    node = root
    while stack or node:
        while node:
            stack.append(node)
            node = node.left
        node = stack.pop()
        if node.val <= prev:
            return False
        prev = node.val
        node = node.right
    return True
```

もしくは色付きスタックを用いて内側のwhileループをなくすことでわかりやすくする
WHITE/GRAYの2色でpre/in/postorderを統一的にiterativeに書ける。再帰を「魔法のように使ってしまう」問題への具体的解法
- https://github.com/naoto-iwase/leetcode/pull/33/changes
```py
      WHITE, GRAY = 0, 1  # WHITE: これから展開, GRAY: 再訪(処理点)
      stack = [(WHITE, root)]
      while stack:
          color, node = stack.pop()
          if node is None:
              continue
          if color == WHITE:
              # preorder: 自分→子 の順にしたいなら、(GRAY, node) を最初に積む
              stack.append((WHITE, node.right))
              stack.append((GRAY, node))            # inorderにしたければここで GRAY を挟む
              stack.append((WHITE, node.left))
              # postorder: 子→自分 の順にしたいなら (GRAY, node) を最後に積む
          else:
              # ここが「訪問（処理）」の場所。pre/in/post は積む順序で決まる
```

### その他コメント
- https://github.com/nittoco/leetcode/pull/35#discussion_r1739979018
> inner にすることは、たとえば、その外側のローカル変数を使うとかで、せざるをえないことがありますが、そうでなければ、class method として並べちゃったほうが私は読みやすいと思いますね。入れ子にすると外側の関数が呼ばれるたびに内側が作られることになるので。

上記の解法だとだいたいclass methodでいい気がする


- https://github.com/kazukiii/leetcode/pull/29#discussion_r1682455638
cppのcoroutineを用いてgenerator相当を実装している(すごい)
[該当コミット](https://github.com/kazukiii/leetcode/commit/23089ba134f9ac3535c178feda7105b45d9aeabd)
コルーチンは「中断・再開できる関数」の一般的な概念. 

## Step3
実装のわかりやすさ（再帰で余計な変数を引き継がない）やり方としてin-order＆generatorパターンを練習
```py
class Solution:
    def isValidBST(self, root):
        val_generator = self.inorder_values(root)
        prev = next(val_generator)
        for val in val_generator:
            if val <= prev:
                return False
            
            prev = val
        return True

    def inorder_values(self, node):
        if node is None:
            return

        # in-orderで値を生成する
        yield from self.inorder_values(node.left)
        yield node.val
        yield from self.inorder_values(node.right)
```