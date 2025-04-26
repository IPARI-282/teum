import * as core from "@actions/core";
import * as github from "@actions/github";
import fetch from "node-fetch";
(async () => {
  try {
    const REVIEWERS = JSON.parse(core.getInput("reviewers"))?.reviewers;
    const REVIEWER_CANDIDATES = REVIEWERS.filter((r) => r.isCandidate).map(
      (r) => r.githubName
    );

    const token = core.getInput("github_token");
    const slackWebhookUrl = core.getInput("slack_webhook_url");
    const octokit = github.getOctokit(token);

    const { owner, repo } = github.context.repo;
    const pullNumber = github.context.issue.number;
    const pr = github.context.payload.pull_request;
    const prAuthor = pr.user.login;

    const actionType = github.context.payload.action;
    const updateNote =
      actionType === "synchronize" ? "🔄 커밋이 추가되었습니다.\n" : "";

    let reviewer;
    const candidates = REVIEWER_CANDIDATES.filter((r) => r !== prAuthor);
    const selected = candidates[Math.floor(Math.random() * candidates.length)];
    await octokit.rest.pulls.requestReviewers({
      owner,
      repo,
      pull_number: pullNumber,
      reviewers: [selected],
    });
    reviewer = REVIEWERS.find((r) => r.githubName === selected);
    if (pr.assignees.length === 0) {
      await octokit.rest.issues.addAssignees({
        owner,
        repo,
        issue_number: pullNumber,
        assignees: [prAuthor],
      });
    }

    const branch = pr.head.ref;
    const labels = [];
    if (branch.includes("feature")) labels.push("🤖 기능 추가");
    if (branch.includes("fix")) labels.push("🐞 버그 수정");
    if (branch.includes("design")) labels.push("🎨 디자인");
    if (labels.length) {
      await octokit.rest.issues.addLabels({
        owner,
        repo,
        issue_number: pullNumber,
        labels,
      });
    }

    const message = {
      text: `${updateNote}<@${reviewer.slackUserId}>님! PR 리뷰 부탁드립니다.\n👉 <${pr.html_url}|${pr.title}>`,
    };

    const res = await fetch(slackWebhookUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(message),
    });

    if (!res.ok) throw new Error(`Slack 전송 실패: ${res.statusText}`);
  } catch (e) {
    core.setFailed(e.message);
  }
})();
