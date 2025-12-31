## Step1
前問と同じようにDFS/BFSを使えば解けそうだと思ったが, 中々うまくいかなかったのでClaudeにヒントをもらいながら書いた.

- DFS
- in-placeではない(非破壊)方法で解く
- スタックは1つにする.スタックに(新しい木の現在ノード, roo1のノード, root2のノード)を入れる. 
スタックに格納されている3つの要素は同じ位置のノードを表す.

時間計算量: O(min(m, n)), 空間計算量: O(min(m, n))
```py
class Solution:
    def mergeTrees(self, root1: Optional[TreeNode], root2: Optional[TreeNode]) -> Optional[TreeNode]:
        if root1 is None and root2 is None:
            return None
        
        if root1 is None:
            return root2
        
        if root2 is None:
            return root1

        def get_children(node):
            if node.left is None:
                left = None
            else:
                left = node.left
            if node.right is None:
                right = None
            else:
                right = node.right

            return left, right

        merged_head = TreeNode(root1.val + root2.val)
        stack = [(merged_head, root1, root2)]
        while stack:
            node, node1, node2 = stack.pop()
            left1, right1 = get_children(node1)
            left2, right2 = get_children(node2)
            if left1 is not None and left2 is not None:
                node.left = TreeNode(left1.val + left2.val)
                stack.append((node.left, left1, left2))
            
            elif left1 is not None:
                # left2の後続ノードはないので, 残りはleft1をつなげればいい
                # 元の木とマージ後の木を一部共有するパターン
                node.left = left1
            
            elif left2 is not None:
                node.left = left2
            
            if right1 is not None and right2 is not None:
                node.right = TreeNode(right1.val + right2.val)
                stack.append((node.right, right1, right2))
            
            elif right1 is not None:
                node.right = right1
            
            elif right2 is not None:
                node.right = right2

        
        return merged_head
```

- left, rightで同じ処理をしているので関数化する. early returnが使えるので`elif`を除くことができる.

```py
class Solution:
    def mergeTrees(self, root1: Optional[TreeNode], root2: Optional[TreeNode]) -> Optional[TreeNode]:
        if root1 is None and root2 is None:
            return None
        
        if root1 is None:
            return root2
        
        if root2 is None:
            return root1

        def get_merged_child(node, child1, child2, attr):  # attr = "left" or "right"
            """
                child1とchild2をマージする関数
            """
            if attr not in ["left", "right"]:
                raise ValueError("invalid attribute")
            
            if child1 is None:
                setattr(node, attr, child2)
                return None

            if child2 is None:
                setattr(node, attr, child1)
                return None
            
            merged_child = TreeNode(child1.val + child2.val)
            setattr(node, attr, merged_child)
            return merged_child
            
        merged_head = TreeNode(root1.val + root2.val)
        stack = [(merged_head, root1, root2)]
        while stack:
            node, node1, node2 = stack.pop()
            left1, right1 = node1.left, node1.right
            left2, right2 = node2.left, node2.right
            merged_left_child = get_merged_child(node, left1, left2, "left")
            merged_right_child = get_merged_child(node, right1, right2, "right")
            if merged_left_child is not None:
                stack.append((merged_left_child, left1, left2))
            if merged_right_child is not None:
                stack.append((merged_right_child, right1, right2))
        
        return merged_head
```

## Step2 他の人のコード・コメントなどを見る
- 再帰DFS
    - 下の階層に「マージしたサブツリーを作って返して」と頼んで, 返ってきたものを自分の子としてリンクを繋ぐ方法. 
    - 毎回の再帰で新たにノードを作成し, そこに子を繋ぐ.（非破壊）

「会社の組織図をマージする」2つの会社が合併するとき:
同じ役職が両方にある → 2人の担当業務を合算した新しいポジションを作る
片方にしかない → その部門をそのまま引き継ぐ
各部長に「自分の部下たちをマージして、新しい組織図を作って報告して」と頼む。部長は課長に同じことを頼み、課長は係長に...と続く。 最終的に社長（root）のところに完成した組織図が返ってくる。
以上のようなイメージ

時間計算量: O(min(m, n)) 空間計算量: O(m + n) // 両木のすべてのノードを探索するまで新しいノードを作成するので
- `if node1 is None: return node2`のようにコピーせず参照をそのまま返す方法があるが, 元の木が削除される可能性があるのであまりやりたくない.

```py
class Solution:
    def mergeTrees(self, root1: Optional[TreeNode], root2: Optional[TreeNode]) -> Optional[TreeNode]:
        if root1 is None and root2 is None:
            return None
    
        if root1 is None:
            node = TreeNode(root2.val) # 新しいノードを作る
            node.left = self.mergeTrees(None, root2.left)
            node.right = self.mergeTrees(None, root2.right)
            return node
        
        if root2 is None:
            node = TreeNode(root1.val)
            node.left = self.mergeTrees(root1.left, None)
            node.right = self.mergeTrees(root1.right, None)
            return node
        
        node = TreeNode(root1.val + root2.val)
        node.left = self.mergeTrees(root1.left, root2.left)
        node.right = self.mergeTrees(root1.right, root2.right)
        
        return node

```

- https://discord.com/channels/1084280443945353267/1192736784354918470/1192805202684805120
上記の再帰は以下のように書き換えられる. 確かに以下のようにすれば`mergeTrees`を呼び出す回数が少なくなる.
```py
def mergeTrees(self, root1: Optional[TreeNode], root2: Optional[TreeNode]) -> Optional[TreeNode]:
        if not (root1 or root2):
            return None

        merged = TreeNode()
        merged.val = 0
        root1_left = None
        root1_right = None
        root2_left = None
        root2_right = None
        if root1 is not None:
            merged.val += root1.val
            root1_left = root1.left
            root1_right = root1.right
        if root2 is not None:
            merged.val += root2.val
            root2_left = root2.left
            root2_right = root2.right
        merged.left = self.mergeTrees(root1_left, root2_left)
        merged.right = self.mergeTrees(root1_right, root2_right)
        return merged
```

- ダブルポインタを使った再帰
https://discord.com/channels/1084280443945353267/1262688866326941718/1297934906189549599
https://discord.com/channels/1084280443945353267/1262688866326941718/1298575468353556501
- pythonとは仕組みが違うが, GoやC++で使える方法でマージ後のノード`merged`のポインタを引数にすると「親の子として繋ぐ」ことができない. ダブルポインタは, 参照を格納している変数の場所, つまり親の子(left/right)がどこに入っているかを指し示すので直接親のleft/rightに書き込むことができる.
- pythonだと属性として渡すような方法に相当する？

```py
def set_node(parent, attr):
    setattr(parent, attr, TreeNode(10))
```

- https://github.com/seal-azarashi/leetcode/pull/22#discussion_r1778932434
> えーっと、もうちょっと生々しく、どのように、この mergeTrees が使われるか想像しませんか。
> この木構造は、何かを表していて mergeTrees 以外の破壊的な関数が存在しないならば、木の一部を共有してもいいわけですが、そうでないならば、このライブラリーを使う人にびっくりさせると思います。
> それで、どんなユースケースでこの mergeTrees は使われるんでしょうか。

共有が許されるケース
- 木が不変
- mergeTrees後に元の木を使わない
- ライブラリ内に完結していて外にもれない

共有が危険なケース
- 元の木を再利用する可能性
- 返した木を変更する可能性（元の木も変わる）
- 複数の場所から同時に参照される

- https://github.com/tarinaihitori/leetcode/pull/23/changes/BASE..3661cef8b334d992a50e919393c5db1b8e22f9e0#r1919824481
> Python は、メンバ変数へのポインターが持てないので、どうしても繰り返し感がでますね。
> C++ だとどこに書き込むかをスタックに積むことができるので、少し簡単になるのです。それを擬似的に Python で表現してみました。
- C++だとダブルポインタで書き込み先を直接スタックに積めるがPythonは不可能なので同じ操作を2回繰り返さないといけない.
- Pythonだと`setattr`, `getattr`, `attrgetter`あたりを使うと良さそう

## Step3
再帰DFS＆非破壊がバランス良さそう
```py
class Solution:
    def mergeTrees(self, root1: Optional[TreeNode], root2: Optional[TreeNode]) -> Optional[TreeNode]:
        if root1 is None and root2 is None:
            return None
        
        merged = TreeNode()
        root1_left = None
        root1_right = None
        root2_left = None
        root2_right = None 
        if root1 is not None:
            merged.val += root1.val
            root1_left = root1.left
            root1_right = root1.right
        if root2 is not None:
            merged.val += root2.val
            root2_left = root2.left
            root2_right = root2.right

        merged.left = self.mergeTrees(root1_left, root2_left)
        merged.right = self.mergeTrees(root1_right, root2_right)
        return merged
```