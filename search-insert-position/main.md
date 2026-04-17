35. Search Insert Position
Given a sorted array of distinct integers and a target value, return the index if the target is found. If not, return the index where it would be if it were inserted in order.
You must write an algorithm with O(log n) runtime complexity.

Example 1:
Input: nums = [1,3,5,6], target = 5
Output: 2

Example 2:
Input: nums = [1,3,5,6], target = 2
Output: 1

Example 3:
Input: nums = [1,3,5,6], target = 7
Output: 4

Example 4:
Input: nums = [1,3,5,6], target = 4
Output: 2

Example 5:
Input: nums = [-1,3,5,6], target = 0
Output: 1

Constraints:
- 1 <= nums.length <= 10^4
- -10^4 <= nums[i] <= 10^4
- nums contains distinct values sorted in ascending order.
- -10^4 <= target <= 10^4

Approach
- bisect_left相当を実装すれば良さそう
- 閉区間で実装をした
- left > rightでループが終わるのでleftが挿入位置を表すことになる

時間計算量：O(logn)
```py
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        if not nums:
            # error
            pass
        
        left, right = 0, len(nums) - 1
        while left <= right:
            mid = (left + right) // 2
            if nums[mid] == target:
                return mid
            
            if nums[mid] < target:
                left = mid + 1
            else:
                right = mid - 1
        
        return left
```
follow up
- なぜ`left`が挿入位置になるのか？
    - `left`は「targetより小さい要素の右端の次」を常に指している
    - `right`は「targetより大きい要素の左端の前」を常に指している
    - ループ終了時に、nums[right] < target < nums[left]という関係がなりたつ

- `bisect_right` -> ある値の範囲の終端を探す(targetより大きい要素の左端の1個前を表すので)
- `bisect_left` -> ある値の最初の出現位置を探す
- 重複要素がある場合どう書く？
- 再帰で実装するパターン

- 半開区間で実装すると以下のようになる
```py
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        if not nums:
            # error
            pass
        
        left, right = 0, len(nums)
        while left < right:
            mid = (left + right) // 2
            if nums[mid] == target:
                return mid
            
            if nums[mid] < target:
                left = mid + 1
            else:
                right = mid
        
        return left
```

- 開区間（番兵つき）
  - left, rightともに番兵。leftは「ここまでtarget未満」、rightは「ここからtarget以上」
  - 不変条件: ∀ i <= left, nums[i] < target / ∀ i >= right, nums[i] >= target
  - 未調査領域は (left, right) の開区間。right - left == 1 で未調査が消滅して終了
  - leftもrightも確定域に含まれるので、midの更新は+1/-1なしでよい
```py
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        left = -1          # 番兵: leftとそれより左はtarget未満
        right = len(nums)  # 番兵: rightとそれより右はtarget以上
        while right - left > 1:
            mid = (left + right) // 2
            if nums[mid] < target:
                left = mid
            else:
                right = mid
        return right
```

- 再帰
```py
class Solution: 
    def searchInsert(self, nums: List[int], target: int) -> int:
        def searchInsertHelper(left, right):
            mid = (left + right) // 2
            if nums[mid] == target:
                return mid

            if left > right:
                return left

            if nums[mid] < target:
                left = mid + 1
                return searchInsertHelper(left, right)

            if nums[mid] > target:
                right = mid - 1
                return searchInsertHelper(left, right)
        
        return searchInsertHelper(0, len(nums) - 1)
```

## Step2 他の人のコード・コメントを読む

### left, rightの意味を「コードから」読み取る — 変数名の語感に騙されない
[seal-azarashi#38](https://github.com/seal-azarashi/leetcode/pull/38) -> [コメント](https://github.com/seal-azarashi/leetcode/pull/38#discussion_r1836463140)
> いや、私の抵抗感がどこから来ているかというと、left, right はそれぞれ何を満たしている値だと思ってループを回していて、それがループから出たときに何が満たされているのかの認識がふわふわしているように思っています。

> 意味を「変数名」の語感から理解しようとしていますね。
> しかし、left に関する行、つまり、たとえば、
> left = 0; left = middle + 1;
> から left はこういう意味であるといって欲しいのです。

left, rightが何を表すかは変数名ではなく**代入文（初期値と更新式）から導出する**。`left = mid + 1`としているなら、`nums[mid] < target`を確認した上でやっているのだから、「leftより左はすべてtarget未満」という不変条件が成り立つ。これがコードから読み取れる「leftの意味」。

### 不変条件こそが二分探索の本体
[seal-azarashi#38](https://github.com/seal-azarashi/leetcode/pull/38) -> [コメント](https://github.com/seal-azarashi/leetcode/pull/38#discussion_r1837596483)
> たとえば、
> left は ∀ i < left, nums[i] < target を満たします。
> right は ∀ i >= right, target <= nums[i] を満たします。
> これならば分かります。

半開区間 `[left, right)` の二分探索における不変条件を日本語で噛み砕くと：
- **leftより左は調査済みで、全部targetより小さいと確定している**
- **right以降は調査済みで、全部target以上と確定している**
- **leftからright-1までが未調査領域**

```
[target未満が確定] [未調査] [target以上が確定]
 0 ... left-1      left ... right-1    right ... n-1
```

この不変条件は3つの場面で成り立つ：
1. **初期値**: `left = 0`, `right = len(nums)` のとき、「0より左」も「len(nums)以降」も空集合。空集合に対して「全部〜」は自明に真（何も調べてない状態で不変条件が成立する）
2. **更新時**: `nums[mid] < target` → midはtarget未満確定なので左の確定域に入れる(`left = mid + 1`)。`nums[mid] >= target` → midはtarget以上確定なので右の確定域に入れる(`right = mid`)。どちらも不変条件を壊さない
3. **ループ終了時**: `left == right`で未調査領域が消滅する。不変条件がそのまま残るので、「leftより左は全部target未満、left(=right)以降は全部target以上」→ leftが挿入位置

**なぜ`left == right`になるのか**: ループ条件は`left < right`。各反復で`left = mid + 1`か`right = mid`のどちらかが実行される。`mid = (left + right) // 2`なので`left <= mid < right`が常に成り立ち、どちらの更新でも`right - left`は必ず1以上減る。よっていつか`left >= right`になりループを抜ける。さらに、更新は`left`を右に動かすか`right`を左に動かすかしかないので、`left`が`right`を飛び越えることはなく、必ず`left == right`で停止する。

### 「仕事の引き継ぎ」メタファー — ループの各反復を人の交代と見る
[Ryotaro25#45](https://github.com/Ryotaro25/leetcode_first60/pull/45) -> [コメント](https://github.com/Ryotaro25/leetcode_first60/pull/45#discussion_r1888181919)
> 「この関数の仕事を手作業でやっているとしましょう。シフト制で SearchInsertIndex の呼び出しが起きるごとに、人が交代します。
> あなたは、当番で SearchInsertIndex の呼び出しがおきたという連絡を受けて、仕事につきます。
> start, end, nums, target が与えられました。
> ここまで働いている人たちがきちんと仕事をしていたら、start, end, nums, target についてどのようなことがいえますか。」

ループ不変条件の理解を確認するための強力なメタファー。前任者から引き継いだstart, endには「前任者たちが正しく仕事をした結果」が詰まっている。その意味を言語化できなければ、二分探索を理解しているとは言えない。

### 初期値と不変条件の整合性 — 辻褄合わせが必要になる理由
[naoto-iwase#24](https://github.com/naoto-iwase/leetcode/pull/24) -> [コメント](https://github.com/naoto-iwase/leetcode/pull/24#discussion_r1835012050)
> left = mid と書いているので、おそらく left は「target がこことここよりも左にはないと分かる最大のインデックス」というつもりで書いているのでしょうが、そうすると、初期値が 0 になっているので、はじめの状態と意味に整合性がないんですね。それで最後に辻褄あわせが必要になっています。

初期値 `left = 0` で `left = mid`（+1なし）で更新すると、不変条件がループの最初から成立しない。その結果、ループ後に場合分けによる後処理が必要になる。**後処理が生まれるのは不変条件の設計が甘い証拠**。正しく `left = mid + 1` と更新すれば、不変条件は最初から最後まで保たれ、後処理は不要になる。

### 更新式が「控えめ」だと停滞する
[naoto-iwase#24](https://github.com/naoto-iwase/leetcode/pull/24) -> [コメント](https://github.com/naoto-iwase/leetcode/pull/24#discussion_r1835035987)
> 誤った更新式は1だけ控えめなので、left, rightは常に1だけずれており、最終的にright - left == 1で仕事が停滞してしまいます。

`left = mid`（+1なし）とすると、`mid`の情報は既に確認済みなのに区間に含め続ける。結果としてright - left == 1で進まなくなり、ループ後に残り2要素を場合分けする羽目になる。正しい更新は「確認済みのmidを区間から追い出す」こと。

### 正確な言語化 — 「target以上」と「targetより大きい」は違う
[mamo3gr#39](https://github.com/mamo3gr/arai60/pull/39) -> [コメント](https://github.com/mamo3gr/arai60/pull/39#discussion_r2766653756)
> targetの時と等しい場合は早期returnがあるので、target以上ではなくtargetより大きいになりますね
> どちらの解釈でもコードは変わらないし動くんですが、正確に言語化することが大事だと思ってます

早期returnで `nums[mid] == target` を処理した後のelse節では、`nums[mid] >= target`のうち等号は除外されている。コードとしては同じ動作でも、**不変条件を正確に記述する習慣**が他の二分探索問題への応用力につながる。

### 二分探索 = 単調述語の境界探索
[naoto-iwase#24](https://github.com/naoto-iwase/leetcode/pull/24)
> 単調述語 False → True の切り替わり点、すなわち「最初に True になる最小の i（first True）」を返す。

`first_true`/`last_true`の抽象化。二分探索の本質は「ソート済み配列から値を探す」ではなく、`[false, false, ..., true, true, ...]`と単調に変化する述語の境界を見つけること。`lower_bound`は`pred(i) := nums[i] >= target`のfirst true、`upper_bound`は`pred(i) := nums[i] > target`のfirst true。この視点を持てば、あらゆる二分探索問題に同じフレームワークで臨める。

### 二分探索の理解度チェックリスト
[Ryotaro25#45](https://github.com/Ryotaro25/leetcode_first60/pull/45) / [mamo3gr#39](https://github.com/mamo3gr/arai60/pull/39)
> 1. 二分探索を、 [false, false, false, ..., false, true, true, ture, ..., true] と並んだ配列があったとき、 false と true の境界の位置を求める問題、または一番左の true の位置を求める問題と捉えているか？
> 2. 位置を求めるにあたり、答えが含まれる範囲を狭めていく問題と捉えているか？
> 3. 範囲を考えるにあたり、閉区間・開区間・半開区間の違いを理解できているか？
> 4. 用いた区間の種類に対し、適切な初期値を、理由を理解したうえで、設定できるか？
> 5. 用いた区間の種類に対し、適切なループ不変条件を、理由を理解したうえで、設定できるか？
> 6. 用いた区間の種類に対し、範囲を狭めるためのロジックを、理由を理解したうえで、適切に記述できるか？

### 停止性の議論
[seal-azarashi#38](https://github.com/seal-azarashi/leetcode/pull/38) -> [コメント](https://github.com/seal-azarashi/leetcode/pull/38#discussion_r1844889283)
> 閉区間の場合、left <= middle <= right ですね。
> `left = middle + 1;`または`right = middle - 1;`が起き、right - left は必ず1以上減っていくので、0未満になりますね。
> 半開区間の場合は、left <= middle < right ですね。
> `left = middle + 1;`または`right = middle;`が起きると、やはり right - left は必ず1以上減っていき、0以下になりますね。

不変条件・正当性に加えて、ループが**必ず終了する**ことの証明も重要。各反復で`right - left`が必ず1以上減ることを示せばよい。閉区間では`mid ± 1`で更新するので自明。半開区間では`left = mid + 1`か`right = mid`だが、`left <= mid < right`なのでどちらでも区間は狭まる。

### トップダウンで考える — 答えから逆算しない
[Ryotaro25#45](https://github.com/Ryotaro25/leetcode_first60/pull/45) -> [コメント](https://github.com/Ryotaro25/leetcode_first60/pull/45#discussion_r1905505478)
> 最終的な挙動からボトムアップに思考しているように見え、違和感を感じました。二分探索の問題のモデルからトップダウンに考えていき、その内容を記述するのが良いと思います。

「end = mid - 1にするとstart > endが起きるからダメ」というのは結果からの逆算。そうではなく「midの位置に対象があるかもしれないから、区間を狭めつつmidを含める → end = mid」とモデルから演繹的に導くのが正しい思考。

### 「探索範囲にtargetがある」は不正確
[seal-azarashi#38](https://github.com/seal-azarashi/leetcode/pull/38) -> [コメント](https://github.com/seal-azarashi/leetcode/pull/38#discussion_r1838077397)
> これは単純に間違いで、[0, 1, 2, 3] で 2 を探すと、まずはじめに、mid == 2 になるので、次のループでは left = 0, right = 2 ですね。

「[left, right)の範囲内にtargetが存在する」という理解は誤り。`[0,1,2,3]`でtarget=2を探すと、mid=2でnums[2]=2を見つけてright=2にするが、[0,2)の範囲にtarget=2は含まれない。正しくは「leftより左は全部target未満、right以降は全部target以上」という**確定域の不変条件**で考えるべき。探索範囲ではなく、確定域に注目する。
