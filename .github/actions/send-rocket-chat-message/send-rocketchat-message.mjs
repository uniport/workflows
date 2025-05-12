#!/usr/bin/env node

// send-rocketchat-message-universal.mjs
// Sends a custom message to Rocket.Chat via a Webhook URL
// Usage: node scripts/send-rocketchat-message-universal.mjs <rocketchat_webhook_url> <channel> "<message>"

// Check if required arguments are provided
if (process.argv.length < 5) {
  console.error(`
  Usage: ${process.argv[1].split('/').pop()} <rocketchat_webhook_url> <channel> "<message>"
    
  Note: The message should be enclosed in double quotes to handle spaces and special characters.
`);
  process.exit(1);
}

// Assign arguments
const [, , rocketchatWebhookUrl, channel, message] = process.argv;

// Send the message to Rocket.Chat (webhook) using fetch
try {
  const response = await fetch(rocketchatWebhookUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      channel,
      text: message,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Failed to send message: ${response.status} - ${errorText}`);
  }

  console.log('Message sent successfully!');
} catch (error) {
  console.error('Error sending message:', error.message);
  process.exit(1);
}
