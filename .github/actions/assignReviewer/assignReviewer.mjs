import * as core from '@actions/core'
import * as github from '@actions/github'
import fetch from 'node-fetch'

;(async () => {
  try {
    /**
     * githubName: GitHub 의 username
     * slackUserId: Slack -> 사용자프로필 -> 메뉴 -> 멤버 ID 복사
     */
    const REVIEWERS = JSON.parse(core.getInput('reviewers'))?.reviewers
    const REVIEWER_CANDIDATES = REVIEWERS.filter((reviewer) => reviewer.isCandidate).map(
      (reviewer) => reviewer.githubName,
    )

    console.log('Reviewer Candidates:', REVIEWER_CANDIDATES)
    console.log('Reviewer Info:', REVIEWERS)
    const token = core.getInput('github_token')
    const slackWebhookUrl = core.getInput('slack_webhook_url')
    const octokit = github.getOctokit(token)

    const { owner, repo } = github.context.repo
    const pullNumber = github.context.issue.number
    const prURL = github.context.payload.pull_request.html_url
    const prTitle = github.context.payload.pull_request.title ?? '새로운 PR'
    const prAuthorGithubName = github.context.payload.pull_request.user.login

    let reviewer
    // 이미 리뷰어가 할당되지 않은 경우에만, 리뷰어 할당
    if (github.context.payload.pull_request.requested_reviewers.length > 0) {
      console.log('Reviewer already assigned')
      reviewer = REVIEWERS.find(
        (reviewer) =>
          reviewer.githubName === github.context.payload.pull_request.requested_reviewers[0].login,
      )
    } else {
      // 랜덤 리뷰어 선정
      const prReviewerCandidates = REVIEWER_CANDIDATES.filter(
        (reviewerGithubName) => reviewerGithubName !== prAuthorGithubName,
      )
      console.log('PR Reviewer Candidates:', prReviewerCandidates)
      const randomIndex = Math.floor(Math.random() * prReviewerCandidates.length)
      const randomReviewerGithubName = prReviewerCandidates[randomIndex]
      console.log(`Selected reviewer: ${randomReviewerGithubName}`)
      await octokit.rest.pulls.requestReviewers({
        owner,
        repo,
        pull_number: pullNumber,
        reviewers: [randomReviewerGithubName],
      })
      reviewer = REVIEWERS.find((reviewer) => reviewer.githubName === randomReviewerGithubName)
    }

    console.log(`Assignee: ${prAuthorGithubName}`)
    // Assignee가 없는 경우에만 Assignee 할당
    if (github.context.payload.pull_request.assignees.length > 0) {
      console.log('Assignee already assigned')
    } else {
      await octokit.rest.issues.addAssignees({
        owner,
        repo,
        issue_number: pullNumber,
        assignees: [prAuthorGithubName],
      })
    }

    // branch 이름 앞에 feature, fix 가 있으면 라벨 추가
    const branchName = github.context.payload.pull_request.head.ref
    if (branchName.includes('feature')) {
      await octokit.rest.issues.addLabels({
        owner,
        repo,
        issue_number: pullNumber,
        labels: ['🤖 기능 추가'],
      })
    } else if (branchName.includes('fix')) {
      await octokit.rest.issues.addLabels({
        owner,
        repo,
        issue_number: pullNumber,
        labels: ['🐞 버그 수정'],
      })
    } else if (branchName.includes('design')) {
      await octokit.rest.issues.addLabels({
        owner,
        repo,
        issue_number: pullNumber,
        labels: ['🎨 디자인'],
      })
    }

    // Slack 메시지 전송
    const escapedPRTitle = prTitle.replaceAll('<', '&lt;').replaceAll('>', '&gt;')
    const slackMessage = {
      text: `<@${reviewer.slackUserId}>님! FE PR 리뷰 부탁드립니다. :pray: \n- <${prURL}|${escapedPRTitle}>`,
    }

    const response = await fetch(slackWebhookUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(slackMessage),
    })

    if (!response.ok) {
      throw new Error(`Slack message failed: ${response.statusText}`)
    }

    console.log(`Sent Slack message to ${reviewer.slackUserId}`)
  } catch (error) {
    core.setFailed(error.message)
  }
})()
