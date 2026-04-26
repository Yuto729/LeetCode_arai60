779. K-th Symbol in Grammar
We build a table of n rows (1-indexed). We start by writing 0 in the 1st row. Now in every subsequent row, we look at the previous row and replace each occurrence of 0 with 01, and each occurrence of 1 with 10.
- For example, for n = 3, the 1st row is 0, the 2nd row is 01, and the 3rd row is 0110.
Given two integer n and k, return the kth (1-indexed) symbol in the nth row of a table of n rows.

Example 1:
Input: n = 1, k = 1
Output: 0
Explanation: row 1: 0

Example 2:
Input: n = 2, k = 1
Output: 0
Explanation: 
row 1: 0
row 2: 01

Example 3:
Input: n = 2, k = 2
Output: 1
Explanation: 
row 1: 0
row 2: 01

Constraints:
- 1 <= n <= 30
- 1 <= k <= 2^n - 1

Approach:
- よく遷移を観察すると、row(n)の前半はrow(n-1)になっている。ということはrowの長さがkを超えたらearly returnできそう
- forループでrowの長さがkを越えるまで 0->01, 1->10に置き換える操作をする

上記の方法の穴
- 時間計算量は、O(log k) < 30なので問題ないが、空間計算量がO(k)になるのでMLEになってしまう。
- Pythonでは文字列はimmutableなので置換操作にO(n)かかるので実際は時間計算量はもっと大きい

Give upし、AIに聞く
💡 空間計算量が大きいので、全てを計算せず n, kから逆算してピンポイントに文字を特定する方針にする

row(n - 1)からrow(n)を作る過程を考えると、k番目の文字に至るまでにすでに変換済みの2 * k文字が前にあることになる。つまりnのk番目はn - 1 の (kが偶数の時はk / 2, 奇数の時は k // 2 + 1)番目の文字を変換したもの。変換後は二文字になるので、kが偶数の時は変換後の後者、kが奇数の時は変換後の前者になる。これを愚直に書き、条件を整理したもの

- XORをとっているのは、parentと(k + 1) % 2を真理値表で書いて整理したもの
```py
class Solution:
    def kthGrammar(self, n: int, k: int) -> int:
        # nから逆算する。
        if n == 1:
            return 0

        parent = self.kthGrammar(n - 1, (k + 1) // 2)
        # XORをとる
        return parent ^ (k + 1) % 2
```

bottom upでも解いてみる
```py


```