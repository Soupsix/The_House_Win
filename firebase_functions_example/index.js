const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * FEATURE 2: Bet Result Notification
 * Triggered when a bet document is updated (status changes to 'won' or 'lost').
 */
exports.onBetResultFinalized = functions.firestore
  .document("bets/{betId}")
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const prevData = change.before.data();

    // Only proceed if status changed to finished
    if (prevData.status === "pending" && (newData.status === "won" || newData.status === "lost")) {
      const userId = newData.userId;
      
      // Get User FCM Token and Settings
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) return null;
      
      const user = userDoc.data();
      const settings = user.notificationSettings || {};
      
      // Check if user opted out of bet results
      if (settings.betResults === false) return null;
      
      const token = user.fcmToken;
      if (!token) return null;

      const isWin = newData.status === "won";
      
      const payload = {
        token: token,
        notification: {
          title: isWin ? "🎉 Congratulations!" : "😢 Bet Lost",
          body: isWin ? `You won your bet and earned ${newData.rewardAmount} Coins.` : "Better luck next time.",
        },
        data: {
          type: isWin ? "bet_win" : "bet_lose",
          betId: context.params.betId,
          route: "/bets/detail",
        },
      };

      try {
        await messaging.send(payload);
        console.log(`Sent bet result to user ${userId}`);
      } catch (error) {
        console.error("Error sending FCM:", error);
      }
    }
    return null;
});

/**
 * FEATURE 3: Match Finished Notification
 * Triggered when match status changes to 'finished'.
 */
exports.onMatchFinished = functions.firestore
  .document("matches/{matchId}")
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const prevData = change.before.data();

    if (prevData.status !== "finished" && newData.status === "finished") {
      const payload = {
        topic: "all_users", // Alternatively, target users who bet on this match
        notification: {
          title: "🏁 Final Score",
          body: `${newData.homeTeam} vs ${newData.awayTeam} has ended!`,
        },
        data: {
          type: "match_finished",
          matchId: context.params.matchId,
          route: "/matches/detail/" + context.params.matchId,
        },
      };

      await messaging.send(payload);
    }
    return null;
});

/**
 * FEATURE 8: Odds Changed Notification
 * Triggered when match odds change.
 */
exports.onOddsChanged = functions.firestore
  .document("matches/{matchId}")
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const prevData = change.before.data();

    // Check if odds object changed
    if (JSON.stringify(prevData.odds) !== JSON.stringify(newData.odds)) {
      const payload = {
        topic: `match_${context.params.matchId}`, // Users subscribe to this topic when viewing/betting
        notification: {
          title: "📈 Odds Updated",
          body: `The odds for ${newData.homeTeam} vs ${newData.awayTeam} have changed.`,
        },
        data: {
          type: "odds_changed",
          matchId: context.params.matchId,
          route: "/matches/detail/" + context.params.matchId,
        },
      };

      await messaging.send(payload);
    }
    return null;
});

/**
 * FEATURE 10: Admin Announcement
 * Triggered when admin creates a new announcement in the 'announcements' collection.
 */
exports.onAdminAnnouncement = functions.firestore
  .document("announcements/{announcementId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    const payload = {
      topic: "all_users",
      notification: {
        title: data.title || "Announcement",
        body: data.body || "New update available.",
      },
      data: {
        type: "admin_announcement",
        route: data.route || "/",
      },
    };

    await messaging.send(payload);
    return null;
});
