Given n pairs of parentheses, write a function to generate all combinations of well-formed parentheses.

Example 1:
Input: n = 3
Output: ["((()))","(()())","(())()","()(())","()()()"]

Example 2:
Input: n = 1
Output: ["()"]
 
Constraints:
- 1 <= n <= 8

## Step1
手作業でどのように行うか考える。open = '(', close = ')'とする。n=3のとき
まず初めはopenでないといけない。その次はopen, closeどちらでもよく、openは３個まで積むことができる。closeが使えるのは、openの個数よりもcloseの個数が少ないときかつ、openの個数が3個以下のとき。openの個数が3個のときはcloseしか使えず、closeも3個積まれたら一つの組みが完成する。

上記をまとめる。各ステップにてopen, closeの分岐が現れるが、それは下記の条件に従って決まる。

- openの個数 = nかつcloseの個数 < n -> closeしか使えない
- openの個数 < n かつ openの個数 > closeの個数 -> open, closeどちらも使える
- openの個数 < n かつ openの個数 = closeの個数 -> openしか使えない
組みを全て求めるので、バックトラックをしながら全組みを求めていく。


約15分。2回ほど提出し直した。
- open_count, close_countをnonlocalにしておらず参照ができなかった
- 引数にすることで修正したが、二番目のif文内で直接open_countを編集していたことで、3つ目のif文に影響が出てしまった。

```py
class Solution:
    def generateParenthesis(self, n: int) -> List[str]:
        open_bracket = "("
        close_bracket = ")"
        result = []
        parentheses = []
        def backtrack(open_count, close_count):
            if open_count == close_count and open_count == n:
                result.append("".join(parentheses))
                return
            
            # 上記の条件を整理し、下記の2つに
            if open_count < n:
                parentheses.append(open_bracket)
                backtrack(open_count + 1, close_count)
                parentheses.pop()
            
            if open_count > close_count:
                parentheses.append(close_bracket)
                backtrack(open_count, close_count + 1)
                parentheses.pop()
        
        backtrack(0, 0)
        return result
```

- 他にバックトラックってどんなパターンがあるか？
- 上記のそれぞれをiterativeに書き換えるとどうなるか？
- iterativeな解法には他にどんなのがあるか？
- CascadingやDPは可能？