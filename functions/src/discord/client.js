// Minimal Discord REST client for the bug-report dispatcher. Uses the
// server-only bot token; never exposed to the Flutter client or repository.
async function createForumThread({ forumId, botToken, threadName, embed }) {
  const response = await fetch(
      `https://discord.com/api/v10/channels/${forumId}/threads`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bot ${botToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name: threadName,
          message: {
            embeds: [embed],
            allowed_mentions: {parse: []},
          },
        }),
      },
  );

  if (!response.ok) {
    const bodyText = await response.text().catch(() => "");
    const error = new Error(`Discord API error ${response.status}: ${bodyText.slice(0, 300)}`);
    error.status = response.status;
    throw error;
  }

  return response.json();
}

module.exports = { createForumThread };
