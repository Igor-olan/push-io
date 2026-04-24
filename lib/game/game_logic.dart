import 'dart:math';
import 'package:flutter/material.dart';

const double kPlayerRadius = 35.0;
const double kBotPlayerRadius = 35.0;
const double kPlayerSpeed = 150.0;
const double kSprintMultiplier = 2.2;
const double kDashForce = 600.0;
const double kDashCooldown = 1.0;
const double kFriction = 0.85;
const double kBounceRestitution = 1.1;
const int kMatchDuration = 180; // 3 minutes

class Player {
  final String id;
  final String name;
  final Color color;
  final bool isBot;
  bool isAlive;
  Offset position;
  Offset velocity;
  double radius;
  bool isSprintActive;
  double dashCooldownRemaining;
  int killCount;
  double surviveTime;

  // Bot AI state
  double _botThinkTimer = 0;
  String _botTarget = '';
  bool _botSprinting = false;
  Offset _botInput = Offset.zero;

  Player({
    required this.id,
    required this.name,
    required this.color,
    required this.position,
    this.isBot = false,
    this.radius = kPlayerRadius,
  })  : isAlive = true,
        velocity = Offset.zero,
        isSprintActive = false,
        dashCooldownRemaining = 0,
        killCount = 0,
        surviveTime = 0;

  void update(double dt, List<Player> allPlayers, Rect mapBounds) {
    if (!isAlive) return;

    // Update cooldowns
    if (dashCooldownRemaining > 0) {
      dashCooldownRemaining -= dt;
      if (dashCooldownRemaining < 0) dashCooldownRemaining = 0;
    }

    // Apply velocity
    position = position + velocity * dt;

    // Apply friction
    velocity = velocity * kFriction;

    // Clamp to map bounds
    final minX = mapBounds.left + radius;
    final maxX = mapBounds.right - radius;
    final minY = mapBounds.top + radius;
    final maxY = mapBounds.bottom - radius;

    if (position.dx < minX) {
      position = Offset(minX, position.dy);
      velocity = Offset(-velocity.dx * 0.5, velocity.dy);
    }
    if (position.dx > maxX) {
      position = Offset(maxX, position.dy);
      velocity = Offset(-velocity.dx * 0.5, velocity.dy);
    }
    if (position.dy < minY) {
      position = Offset(position.dx, minY);
      velocity = Offset(velocity.dx, -velocity.dy * 0.5);
    }
    if (position.dy > maxY) {
      position = Offset(position.dx, maxY);
      velocity = Offset(velocity.dx, -velocity.dy * 0.5);
    }

    // Check if outside map bounds (dead zone)
    if (position.dx < mapBounds.left - radius * 2 ||
        position.dx > mapBounds.right + radius * 2 ||
        position.dy < mapBounds.top - radius * 2 ||
        position.dy > mapBounds.bottom + radius * 2) {
      isAlive = false;
    }

    // Update survive time
    surviveTime += dt;
  }

  void updateBot(double dt, List<Player> allPlayers, Rect mapBounds) {
    if (!isAlive || !isBot) return;

    _botThinkTimer -= dt;
    if (_botThinkTimer <= 0) {
      _botThinkTimer = 0.3 + Random().nextDouble() * 0.4;

      // Pick a target
      final alive = allPlayers.where((p) => p.isAlive && p.id != id).toList();
      if (alive.isNotEmpty) {
        _botTarget = alive[Random().nextInt(alive.length)].id;
      }
      _botSprinting = Random().nextBool();
    }

    // Move toward target
    final target = allPlayers.where((p) => p.id == _botTarget && p.isAlive).firstOrNull;
    if (target != null) {
      final dir = target.position - position;
      final dist = dir.distance;
      if (dist > 0) {
        _botInput = dir / dist;
      }
    } else {
      // Move toward center
      final center = mapBounds.center;
      final dir = Offset(center.dx, center.dy) - position;
      final dist = dir.distance;
      if (dist > 0) {
        _botInput = dir / dist;
      }
    }

    isSprintActive = _botSprinting;
    final speed = isSprintActive ? kPlayerSpeed * kSprintMultiplier : kPlayerSpeed;
    velocity += _botInput * speed * dt * 3;

    // Bot dash
    if (target != null && (target.position - position).distance < kPlayerRadius * 3) {
      if (dashCooldownRemaining <= 0) {
        dash(_botInput);
      }
    }
  }

  void applyInput(Offset direction, bool sprint) {
    if (!isAlive) return;
    isSprintActive = sprint;
    final speed = sprint ? kPlayerSpeed * kSprintMultiplier : kPlayerSpeed;
    if (direction != Offset.zero) {
      velocity += direction * speed;
    }
  }

  void dash(Offset direction) {
    if (!isAlive || dashCooldownRemaining > 0) return;
    if (direction == Offset.zero) return;
    velocity += direction * kDashForce;
    dashCooldownRemaining = kDashCooldown;
  }

  bool checkCollision(Player other) {
    if (!isAlive || !other.isAlive) return false;
    final dist = (position - other.position).distance;
    return dist < (radius + other.radius);
  }

  void resolveCollision(Player other) {
    if (!isAlive || !other.isAlive) return;
    final delta = position - other.position;
    final dist = delta.distance;
    if (dist == 0) return;

    final normal = delta / dist;
    final overlap = (radius + other.radius) - dist;

    // Separate players
    position = position + normal * overlap * 0.5;
    other.position = other.position - normal * overlap * 0.5;

    // Exchange velocities with bounce
    final relVel = velocity - other.velocity;
    final velAlongNormal = relVel.dx * normal.dx + relVel.dy * normal.dy;

    if (velAlongNormal > 0) return;

    final impulse = velAlongNormal * kBounceRestitution;
    velocity = velocity - normal * impulse;
    other.velocity = other.velocity + normal * impulse;
  }
}

class GameState {
  final List<Player> players;
  double timeRemaining;
  bool isRunning;
  bool isPaused;
  Rect mapBounds;
  double mapShrinkTimer;
  static const double kShrinkInterval = 10.0;
  static const double kShrinkAmount = 15.0;

  GameState({
    required this.players,
    required this.mapBounds,
  })  : timeRemaining = kMatchDuration.toDouble(),
        isRunning = true,
        isPaused = false,
        mapShrinkTimer = kShrinkInterval;

  List<Player> get alivePlayers => players.where((p) => p.isAlive).toList();

  Player? get humanPlayer => players.where((p) => !p.isBot).firstOrNull;

  bool get isGameOver {
    final alive = alivePlayers;
    if (alive.length <= 1) return true;
    if (timeRemaining <= 0) return true;
    return false;
  }

  bool get humanWon {
    final human = humanPlayer;
    if (human == null) return false;
    if (!human.isAlive) return false;
    final alive = alivePlayers;
    return alive.length == 1 && alive.first.id == human.id;
  }

  void update(double dt, Offset joystickInput, bool sprint) {
    if (!isRunning || isPaused) return;

    timeRemaining -= dt;
    if (timeRemaining < 0) timeRemaining = 0;

    // Shrink map
    mapShrinkTimer -= dt;
    if (mapShrinkTimer <= 0) {
      mapShrinkTimer = kShrinkInterval;
      _shrinkMap();
    }

    // Update human player
    final human = humanPlayer;
    if (human != null && human.isAlive) {
      human.applyInput(joystickInput, sprint);
    }

    // Update bots
    for (final player in players) {
      if (player.isBot && player.isAlive) {
        player.updateBot(dt, players, mapBounds);
      }
    }

    // Update all players
    for (final player in players) {
      player.update(dt, players, mapBounds);
    }

    // Check collisions
    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        if (players[i].checkCollision(players[j])) {
          players[i].resolveCollision(players[j]);

          // Check if any player got knocked out of bounds
          _checkKnockOut(players[i], players[j]);
        }
      }
    }

    // Mark dead players
    for (final player in players) {
      if (player.isAlive && !mapBounds.contains(player.position)) {
        // Give a moment outside before dying
        if (_isOutside(player)) {
          _killPlayer(player);
        }
      }
    }
  }

  bool _isOutside(Player player) {
    final expanded = mapBounds.inflate(player.radius);
    return !expanded.contains(player.position);
  }

  void _killPlayer(Player player) {
    player.isAlive = false;
    // Credit kill to last person who hit them
  }

  void _checkKnockOut(Player a, Player b) {
    // Handled in update loop
  }

  void _shrinkMap() {
    final shrink = kShrinkAmount;
    mapBounds = Rect.fromLTRB(
      mapBounds.left + shrink,
      mapBounds.top + shrink,
      mapBounds.right - shrink,
      mapBounds.bottom - shrink,
    );
  }
}
