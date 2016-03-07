// Q2048

void() q2048_init = 
{
    local entity fig;

	self.flags = self.flags | FL_NOTARGET;
	total_monsters = 0;

	fig = findradius(self.origin, 2048);
    while (fig)
    {
        if (fig.figure == TRUE)
        {
            T_Damage(fig, world, world, 2048);
        }

        fig = fig.chain;
    }

	q2048_spawn();
	q2048_spawn();
};

void() q2048_spawn = 
{
	local entity pos;

	pos = q2048_get_empty_pos();
	
	if (!pos)
	{
		return;
	}

    if (random() > 0.95)
	    q2048_spawn_entity(4, pos, "");
    else
        q2048_spawn_entity(2, pos, "");
};

void(float monster_score, entity pos, string combined_flag) q2048_spawn_entity =
{
    local string monster_class;
	local entity monster;
	local entity tmp;

    monster_class = q2048_get_monster_class(monster_score);

	monster = spawn();
	monster.classname = monster_class;
	setorigin(monster, pos.origin + '0 0 32');
	monster.figure = 1;
	monster.x = pos.x;
	monster.y = pos.y;
	monster.score = monster_score;
	monster.combined = combined_flag;

    if (monster_class == "monster_dog")
	    monster.spawnfunc = monster_dog;
    else if (monster_class == "monster_army")
        monster.spawnfunc = monster_army;
    else if (monster_class == "monster_enforcer")
        monster.spawnfunc = monster_enforcer;
    else if (monster_class == "monster_zombie")
        monster.spawnfunc = monster_zombie;
    else if (monster_class == "monster_ogre")
        monster.spawnfunc = monster_ogre;
    else if (monster_class == "monster_demon1")
        monster.spawnfunc = monster_demon1;
    else if (monster_class == "monster_knight")
        monster.spawnfunc = monster_knight;
    else if (monster_class == "monster_hell_knight")
        monster.spawnfunc = monster_hell_knight;
    else if (monster_class == "monster_shalrath")
        monster.spawnfunc = monster_shalrath;
    else if (monster_class == "monster_tarbaby")
        monster.spawnfunc = monster_tarbaby;
    else if (monster_class == "monster_shambler")
        monster.spawnfunc = monster_shambler;
    else if (monster_class == "monster_fish")
        monster.spawnfunc = monster_fish;
    else if (monster_class == "monster_wizard")
            monster.spawnfunc = monster_wizard;

	tmp = self;
	self = monster;

	monster.spawnfunc();
	total_monsters = total_monsters - 1;

	self = tmp;

	if (monster_class == "monster_shambler")
	{
    	sound(self, CHAN_VOICE, "ambience/thunder1.wav", 1, ATTN_NORM);
        centerprint(checkclient(), "2048!");
	}
	else if (monster_class == "monster_fish")
    {
        sound(self, CHAN_VOICE, "items/health1.wav", 1, ATTN_NORM);
        centerprint(checkclient(), "4096!");
    }
    else if (monster_class == "monster_wizard")
    {
        sound(self, CHAN_VOICE, "wizard/wattack.wav", 1, ATTN_NORM);
        centerprint(checkclient(), "8192!");
    }
};

entity() q2048_get_empty_pos =
{
	local entity ent;
	local entity ent_success;
	
	ent = find(world, classname, "info_notnull");
	
	if (q2048_is_free(ent))
	{
	    ent_success = ent;

	    if (random() < 0.4)
	    {
            return ent_success;
	    }
	}		

	while (ent)
	{
		ent = find(ent, classname, "info_notnull");
		if (ent)
		{
            if (q2048_is_free(ent))
            {
                ent_success = ent;

                if (random() < 0.4)
                {
                    return ent_success;
                }
            }
		}
	}

	return ent_success;
};

float(entity pos) q2048_is_free =
{
	local entity ent;
	
	ent = findradius(pos.origin, 128);
	while (ent)
	{
		if (ent.classname != pos.classname)
		{
			return FALSE;
		}
			
		ent = ent.chain;
	}

	return TRUE;
};

void() q2048_fail =
{
	centerprint(checkclient(), "FAIL!");
};

void(float dir) q2048_move =
{
    local float row;
    local float column;
    local float start_row;
    local float start_column;
    local float combined_score;
    local entity fig;
    local entity fig2;
    local entity pos;

    fig = find(world, combined, "1");
    while (fig)
    {
        fig.combined = "";
        fig = find(fig, combined, "1");
    }

    if (dir == 0)
    {
        column = 0;
        while (column <= 3)
        {
            start_row = 1;
            while (start_row <= 3)
            {
                row = start_row;
                while (row > 0)
                {
                    q2048_move_fig(column, row, column, row - 1);

                    row--;
                }

                start_row++;
            }

            column++;
        }
    }
    else if (dir == 1)
    {
        row = 0;
        while (row <= 3)
        {
            start_column = 2;
            while (start_column >= 0)
            {
                column = start_column;
                while (column < 3)
                {
                    q2048_move_fig(column, row, column + 1, row);

                    column++;
                }

                start_column--;
            }

            row++;
        }
    }
    else if (dir == 2)
    {
        column = 0;
        while (column <= 3)
        {
            start_row = 2;
            while (start_row >= 0)
            {
                row = start_row;
                while (row < 3)
                {
                    q2048_move_fig(column, row, column, row + 1);

                    row++;
                }
                start_row--;
            }

            column++;
        }
    }
    else if (dir == 3)
    {
        row = 0;
        while (row <= 3)
        {
            start_column = 1;
            while (start_column <= 3)
            {
                column = start_column;
                while (column > 0)
                {
                    q2048_move_fig(column, row, column - 1, row);

                    column--;
                }

                start_column++;
            }

            row++;
        }
    }

    if (!q2048_moves_possible())
    {
        q2048_fail();
        return;
    }

    q2048_spawn();
};

string(float score) q2048_get_monster_class =
{
    if (score == 2)
        return "monster_dog";
    else if (score == 4)
        return "monster_army";
    else if (score == 8)
        return "monster_enforcer";
    else if (score == 16)
        return "monster_zombie";
    else if (score == 32)
        return "monster_ogre";
    else if (score == 64)
        return "monster_demon1";
    else if (score == 128)
        return "monster_knight";
    else if (score == 256)
        return "monster_hell_knight";
    else if (score == 512)
        return "monster_shalrath";
    else if (score == 1024)
        return "monster_tarbaby";
    else if (score == 2048)
        return "monster_shambler";
    else if (score == 4096)
        return "monster_fish";
    else if (score == 8192)
        return "monster_wizard";
};

void(float column, float row, float new_column, float new_row) q2048_move_fig =
{
    local entity fig;
    local entity fig2;
    local entity pos;
    local float combined_score;

    fig = q2048_find_fig(column, row);
    if (fig)
    {
        fig2 = q2048_find_fig(new_column, new_row);
        if (fig2)
        {
            if (fig.score == fig2.score)
            {
                if ((fig.combined != "1") && (fig2.combined != "1"))
                {
                    combined_score = fig.score + fig2.score;

                    if (combined_score == 16384)
                    {
                        WriteByte (MSG_ALL, SVC_FINALE);
                        WriteString (MSG_ALL, "Congratulations and well done!\nYou scored 16384.\nGet a rest, soldier!");
                    }

                    remove(fig);
                    remove(fig2);
                    pos = q2048_find_pos(new_column, new_row);
                    q2048_spawn_entity(combined_score, pos, "1");

                    total_monsters = total_monsters + combined_score;
                }
            }
        }
        else
        {
            pos = q2048_find_pos(new_column, new_row);
            setorigin(fig, pos.origin + '0 0 32');
            droptofloor();
            fig.x = pos.x;
            fig.y = pos.y;
        }
    }
};

float() q2048_moves_possible =
{
    local float col;
    local float row;
    local entity ent;
    local entity tmp;

    row = 0;
    while (row <= 3)
    {
        col = 0;
        while (col <= 3)
        {
            ent = q2048_find_fig(col, row);

            if (row > 0)
            {
                tmp = q2048_find_fig(col, row - 1);
                if (!tmp || ent.score == tmp.score)
                    return TRUE;
            }

            if (row < 3)
            {
                tmp = q2048_find_fig(col, row + 1);
                if (!tmp || ent.score == tmp.score)
                    return TRUE;
            }

            if (col > 0)
            {
                tmp = q2048_find_fig(col - 1, row);
                if (!tmp || ent.score == tmp.score)
                    return TRUE;
            }

            if (col < 3)
            {
                tmp = q2048_find_fig(col + 1, row);
                if (!tmp || ent.score == tmp.score)
                    return TRUE;
            }

            col++;
        }

        row++;
    }

    return FALSE;
};

entity(float column, float row) q2048_find_fig =
{
    local entity pos;
    local entity fig;

    pos = q2048_find_pos(column, row);

    fig = findradius(pos.origin, 2048);
    while (fig)
    {
        if (fig.x == pos.x)
        {
            if (fig.y == pos.y)
            {
                if (fig.figure == TRUE)
                {
                    return fig;
                }
            }
        }

        fig = fig.chain;
    }

    return world;
};

entity(float column, float row) q2048_find_pos =
{
    local entity ent;
    local string s_row;
    local string s_column;

    s_row = ftos(row);
    s_column = ftos(column);

    ent = find(world, classname, "info_notnull");
    while ((ent.x != s_column) || (ent.y != s_row))
    {
        ent = find(ent, classname, "info_notnull");
    }

    return ent;
};

void() q2048_center_player =
{
    local entity player;
    local entity player_start;

    player = checkclient();
    player_start = find(world, classname, "info_player_start");

    player.velocity = '0 0 0';
    setorigin(player, player_start.origin);
};