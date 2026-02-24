-- Tools to delete from production database
-- Total deleted: 17 tools

DELETE FROM tool_categories WHERE tool_id IN (84, 86, 83, 88, 89, 90, 87, 81, 16, 82, 37, 50, 24, 22, 51, 32, 55);
DELETE FROM tools WHERE id IN (84, 86, 83, 88, 89, 90, 87, 81, 16, 82, 37, 50, 24, 22, 51, 32, 55);

-- Tool names that will be deleted:
-- Jasper AI, Copy.ai, GitHub Copilot, Stable Diffusion, Synthesia, Grammarly, Notion AI
-- Eleven Labs, GitHub Copilot Test, Runway ML, AI工具集导航, 金助理, 智能判决预测, 法律咨询AI, 印象笔记, 百度文库, 沉浸式翻译
