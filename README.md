# shadow_chat

A Flutter project for a simple mobile app that serves as a chat feed for user-created sessions similar to the chat feature of most livestream services. 
It demonstrates Firebase implementation, account-oriented operations, use of logical operations to reduce code length, and various other Flutter tools previously unfamiliar to me as a programmer. 

## Use Cases

- If users are not concerned about having their previous interactions saved like in most messaging apps, this app can be used as an alternative to texting, perfect for those who have limited data plans on their devices.
- For those who are often overwhelmed by the multitudes of features that come in most modern apps, Shadow Chat provides a much simpler and straightforward way of digitally holding conversations, needing only a way of logging in and a way of writing messages.
- For those who hold livestreams regularly, Shadow Chat can offer a number of useful benefits.
  - When playing games or watching media where chat members have the potential to spoil upcoming contents, Shadow Chat can be confined to only the trustworthy viewers watching.
  - If desired, Shadow Chat can be used exclusively to chat with server mods, close friends, and fellow streamers, allowing them to be distinguished more easly from the general population.
  - In the event of technical difficulties with the streaming platform, the entirely separate and independent Shadow Chat will remain operational, allowing everyone to stay involved and keep up with what is happening as the difficulties are attempting to be solved.
- Speaking of reliability, not only could Shadow Chat serve as a strong backup for problems with other apps and services like Zoom or Discord, but since Firebase is provided and maintained by Google, one can safely assume that Shadow Chat is highly unlikely to experience an obstructive crash or error during use, especially not at the same time as whatever it is used as a backup for.

## Features to Know About

- Most errors and failures during use are explained through popup messages, so you shouldn't have to worry about not knowing why something went wrong.
- Because no user-relevant data from the actual chat session is preserved once a session ends, there are virtually no restrictions or requirements for consistency when you choose a username before joining. The only two exceptions are that (1) two session hosts cannot have matching usernames, and (2) a name cannot be used more than once within the same session.
- Though it is currently treated very flexible, you should assume that only valid and active email addresses can be used to create an account. Otherwise, future implementations may silently block an existing account that failed to use a real address.
- Just because creating an account fails once, that does not always mean the account already exists. Pay attention to the error message you get to see why it failed.
- As a rule of thumb, if you are not sure if you can do a certain thing, it should work as long as it is allowed. For example, leaving and rejoining a single session with a different username should work.
- The host must be in the session before it can be joined by others. If the host leaves at any time, all other members automatically exit.
- 
