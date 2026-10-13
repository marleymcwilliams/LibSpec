# Decision queue

Questions only you can answer: anything that changes a statement's meaning, a Norm-layer value or anything frozen, and anything that would make a check weaker. Each entry gives the question, a recommended answer, what breaks if the answer is wrong, and whether it can be undone. At most three entries are open at once, and work never waits on one. "Not yet" is a valid answer.

## Open

### Q1. State interchange over two named operators

- **Question:** Should the statements define interchange as a Prop over two named operators, `Interchange seq par`, with `seqComp` and `parComp` both defined as `combine`, and state `interchange` as `Interchange seqComp parComp`?
- **Recommended answer:** Yes. With one operator, the law follows from `combine_comm` and `combine_assoc`, so it can't fail for any commutative, associative `combine` and catches nothing. With two named operators, JSG V's rule becomes a mutant that can be stated: max on every axis in sequence, `combine` in parallel. On a budget axis with x = 1, x′ = 0, y = 0, y′ = 1, it grades 2 one way and 1 the other.
- **What breaks if wrong:** If yes is the wrong call, the cost is small: two extra definitions in `Defs.lean` that must stay equal to `combine`, and a longer statement to review. If you answer no, `interchange` stays vacuous, and it can't meet the roadmap's rule that every theorem names a mutant that fails it.
- **Can it be undone:** Yes, freely until `statements-v1` is tagged. After that, only with a new statements version and a CHANGELOG line.

## Answered

None yet.
