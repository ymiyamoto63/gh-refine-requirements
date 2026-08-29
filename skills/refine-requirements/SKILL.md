---
name: refine-requirements
description: Turn a rough, business-level requirements memo into a design-ready requirements document through a structured multiple-choice interview. Use this skill whenever the user provides draft or rough requirements, a feature memo from a business manager or stakeholder, or asks to 要件定義 / 要件を詰める / refine requirements / create a requirements document — even if they don't name this skill explicitly. Do not use it for tasks that are already fully specified or for pure research questions.
---

# refine-requirements

You receive rough requirements written by a business manager — typically incomplete, ambiguous, and written in business language — and turn them into a requirements document precise enough to hand to a design phase without the designer having to guess. Work in three phases: investigate the repository, interview the user with multiple-choice questions, write the document.

Do not design the solution and do not write code. The requirements document is the whole deliverable.

## Input

The rough requirements arrive as chat text or as a path to a file (.md / .txt — read it). If neither is given, ask for them before doing anything else. If the input mixes several independent features, propose splitting into one document per feature (the output convention is one file per feature) and let the user choose before interviewing.

## Step 1 — Investigate before asking

Never ask a question you could answer yourself. Before the interview, survey the target project (the current working directory unless told otherwise): `README`, `docs/` (especially `docs/pipeline-config.md` and existing `docs/requirements/*.md`) for conventions and prior decisions, and the code areas the feature touches — similar existing features, screen/routing structure, API patterns, data model. The survey is done the moment you can ground your recommendations; understanding the whole repository is not the goal. Delegate the survey to a read-only exploration subagent (e.g. Explore) only when it is a genuinely wide investigation of a large codebase — keep just its summary in context — and do it yourself when a few targeted searches suffice.

Ambiguities you resolve from the survey instead of asking are inferences, not user decisions: collect them for the 前提 list in the 制約 section so the user can veto a wrong inference when reviewing the document. What the survey cannot resolve is the interview material.

## Step 2 — Interview loop

Enumerate, in one pass, every ambiguity that materially changes what gets built — functional and non-functional together, because a late non-functional finding (compliance, data sensitivity) can reshape functional decisions already made:

- **Functional ambiguities** (the main subject): behavior, screens, data, edge cases, permissions-as-behavior.
- **Non-functional ambiguities that can materially reshape the spec**: authentication/authorization model, personal or sensitive data, data volume / performance at a scale that changes the design, availability of external integrations, legal/compliance constraints. Routine NFRs (general performance wishes, logging conventions) stay off the list.

While enumerating, sweep this checklist of classic omissions in requirements work. It governs enumeration only — whether an item becomes a question follows the impact ordering and budget below, and items obviously irrelevant to this feature are skipped:

- アクターと権限: 誰が使うか、ロールによって挙動が変わるか
- 異常系・エッジケース: 入力不正 / 0件 / 上限超過 / 外部サービス障害時の挙動
- データ: 入出力の形式、保持期間、既存データの移行の要否
- スコープ境界: メモに書かれていないが隣接する機能を、やるのか・やらないのか
- 同時実行・競合、通知・監査ログの要否

Order the list by impact: questions whose answer forks the spec widely come first, so the budget is spent where it matters most.

**Budget: 30 questions — a hard cap, not a target.** A typical memo converges in 8–15 questions over 3–4 rounds. Every option-question actually presented counts, follow-ups included; asking for the input memo, proposing a feature split, and confirming a filename do not. State the running count before each round's questions (e.g. `質問 5–8 / 30`). Stop the moment no material ambiguity remains; anything still open when the budget runs out becomes a 未決定事項 (Step 3).

Present up to 4 related questions per round. Each question:

- 2–4 concrete options, mutually exclusive where possible.
- Mark the recommended option with 「（推奨）」 and a one-line rationale grounded in at least one of: the stated business goal, UI/UX, implementation difficulty, or the repository's current design — and say which. When the ground is the current design, cite the file or directory found in Step 1 (e.g. `src/features/export/`) so the claim is checkable. Leave a recommendation you cannot ground unmarked.
- Use `AskUserQuestion` where the environment provides it (recommended option first, labeled 「（推奨）」); otherwise — e.g. GitHub Copilot — present the options as a numbered list in chat and wait for the answer. Free-text answers outside the options are always valid; fold them in as given.

If an answer contradicts the rough memo or an earlier answer, point out the contradiction and confirm which wins before folding it in (the confirmation counts as a question).

After each round, before presenting the next, append one 決定記録 line per answer to the output file (Step 4 path — settle the slug in the first round; if the file already existed, you are in update mode, Step 4, and append there). A long interview can outlive your context window: the file, not your memory of the conversation, is the durable record, and Step 4 builds the document around these lines.

## Step 3 — Undecided items

Questions still open when the budget is exhausted, or that the user explicitly defers, go into the 未決定事項 section in the format the template shows: the options considered, a recommended provisional answer with rationale, and the impact if it turns out wrong — so the design phase can proceed on the stated assumption instead of stalling. When the decision belongs to someone other than the interviewee (法務、営業部長、外部ベンダーなど — typically a 「わからない」「要確認」 answer), also record 確認先. Never fold a provisional answer into the body of the document as if it were decided.

## Step 4 — Write the document

Output path: `<project_root>/docs/requirements/<feature-slug>.md`, where `<feature-slug>` is a short kebab-case English slug for the feature (e.g. `avatar-upload.md`, `csv-export.md`). Create parent directories if needed. State the filename when you write it; ask only if genuinely ambiguous.

**Update mode:** if the file existed before this interview started (your own Step 2 決定記録 draft doesn't count), read it first. If it describes a different feature that happens to share the slug, pick a different slug. If it is an earlier version of this feature, tell the user and revise it — resolve the 未決定事項 the new answers settle, update affected sections, append to 決定記録. Requirements documents get revised, not rewritten, and existing FR / AC IDs are never renumbered: downstream phases (design, tests, review) cite them.

Write the document content in Japanese unless told otherwise, using exactly this structure — a section with nothing to say gets 「なし」 rather than being removed, so downstream phases can rely on the shape:

```markdown
# <機能名>

## 概要
<何を作るか、1段落>

## 背景・目的
<なぜ作るか。ビジネス上の狙い>

## スコープ
<作る/直すものの具体的な箇条書き>

## 対象外（Non-goals）
<今回は明示的にやらないこと>

## 影響範囲
<この機能が触れるレイヤーを対象プロジェクトの構成に即して具体的に（例: 画面コンポーネント / フロント状態管理 / APIクライアント / バックエンドAPI / サービスロジック / DBスキーマ）。設計・テストフェーズが何に手を入れるかの判断に使う>

## 機能要件
- FR-1: <検証可能な粒度の要件>
- FR-2: …

## 画面・UIフロー
<関係する画面と遷移。既存画面への追加なら既存構造に言及>

## 受け入れ基準
<全 FR を少なくとも1つの AC でカバーする。否定形の FR（「〜しない」「上限を設けない」）にも、その挙動が現れないことを確認する AC を書く。主要な異常系を含め、機械的に検証可能な条件を優先する>
- AC-1: <条件>（検証方法: 自動テスト / 手動確認）
- AC-2: …

## 制約
<既存アーキテクチャ・ライブラリ・規約のうち設計が従うべきもの（Step 1 の調査結果）>

### 前提（調査により確認）
<質問の代わりに Step 1 の調査で仮確定した判断の一覧。誤った推測をユーザーがレビュー時に否認できるよう明示する。なければ「なし」>

## 重大な非機能要件
<仕様に影響する項目のみ。なければ「なし」>

## 未決定事項
- <質問> — 選択肢: <A / B> / 推奨仮置き: <A>（<根拠>）/ 外れた場合の影響: <…> / 確認先: <誰・どの部署>（決定権が回答者以外にある場合のみ）

## 決定記録
<回答された質問ごとに1行（Step 2 で逐次追記済み）。推奨案がそのまま採用された場合も含む — 半年後の設計者が仕様の理由を辿れるように>
- Q1: <質問> → <選ばれた選択肢>（理由: <…>）

## 用語集
<ビジネス用語 ↔ システム上の概念の対応。齟齬が出やすい語のみ>
```

The AC-ID and 検証方法 tag format is compatible with dev-pipeline's requirements-analyst output, so the document can feed straight into a `/dev-pipeline` run.

## Wrap-up

Your final message: the file path written, the number of questions used out of 30, and the list of 未決定事項 with their recommended provisional answers, so the user can act without opening the file. If the user replies with corrections or disagreements, fold them in via update mode — don't restart the interview.

Match the document to what the feature needs: cover the substance, and do not pad with filler sections, boilerplate, or restated context.
