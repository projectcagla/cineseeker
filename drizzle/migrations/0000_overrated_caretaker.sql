CREATE TABLE `account` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`account_id` text NOT NULL,
	`provider_id` text NOT NULL,
	`access_token` text,
	`refresh_token` text,
	`access_token_expires_at` integer,
	`refresh_token_expires_at` integer,
	`scope` text,
	`password` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `account_user_idx` ON `account` (`user_id`);--> statement-breakpoint
CREATE TABLE `availability_snapshot` (
	`tmdb_id` integer NOT NULL,
	`media_type` text DEFAULT 'movie' NOT NULL,
	`region` text DEFAULT 'TR' NOT NULL,
	`provider_id` integer NOT NULL,
	`monetization` text NOT NULL,
	`title` text NOT NULL,
	`poster_path` text,
	`first_seen_at` integer NOT NULL,
	`last_seen_at` integer NOT NULL,
	PRIMARY KEY(`tmdb_id`, `media_type`, `region`, `provider_id`, `monetization`)
);
--> statement-breakpoint
CREATE INDEX `snapshot_region_provider_idx` ON `availability_snapshot` (`region`,`provider_id`);--> statement-breakpoint
CREATE INDEX `snapshot_first_seen_idx` ON `availability_snapshot` (`first_seen_at`);--> statement-breakpoint
CREATE INDEX `snapshot_last_seen_idx` ON `availability_snapshot` (`last_seen_at`);--> statement-breakpoint
CREATE TABLE `session` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`token` text NOT NULL,
	`expires_at` integer NOT NULL,
	`ip_address` text,
	`user_agent` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE UNIQUE INDEX `session_token_unique` ON `session` (`token`);--> statement-breakpoint
CREATE INDEX `session_user_idx` ON `session` (`user_id`);--> statement-breakpoint
CREATE INDEX `session_token_idx` ON `session` (`token`);--> statement-breakpoint
CREATE TABLE `user` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`email` text NOT NULL,
	`email_verified` integer DEFAULT false NOT NULL,
	`image` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `user_email_unique` ON `user` (`email`);--> statement-breakpoint
CREATE TABLE `user_profile` (
	`user_id` text PRIMARY KEY NOT NULL,
	`region` text DEFAULT 'TR' NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE TABLE `user_provider` (
	`user_id` text NOT NULL,
	`provider_id` integer NOT NULL,
	`provider_name` text NOT NULL,
	`logo_path` text NOT NULL,
	`created_at` integer NOT NULL,
	PRIMARY KEY(`user_id`, `provider_id`),
	FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `user_provider_user_idx` ON `user_provider` (`user_id`);--> statement-breakpoint
CREATE TABLE `verification` (
	`id` text PRIMARY KEY NOT NULL,
	`identifier` text NOT NULL,
	`value` text NOT NULL,
	`expires_at` integer NOT NULL,
	`created_at` integer,
	`updated_at` integer
);
--> statement-breakpoint
CREATE INDEX `verification_identifier_idx` ON `verification` (`identifier`);--> statement-breakpoint
CREATE TABLE `watchlist_item` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`tmdb_id` integer NOT NULL,
	`media_type` text DEFAULT 'movie' NOT NULL,
	`title` text NOT NULL,
	`poster_path` text,
	`vote_average` text,
	`release_year` text,
	`status` text DEFAULT 'want' NOT NULL,
	`rating` integer,
	`added_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE UNIQUE INDEX `watchlist_user_tmdb_media_idx` ON `watchlist_item` (`user_id`,`tmdb_id`,`media_type`);--> statement-breakpoint
CREATE INDEX `watchlist_user_status_idx` ON `watchlist_item` (`user_id`,`status`);--> statement-breakpoint
CREATE INDEX `watchlist_added_at_idx` ON `watchlist_item` (`added_at`);