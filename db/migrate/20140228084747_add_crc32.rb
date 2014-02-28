class AddCrc32 < ActiveRecord::Migration
  def up
    execute <<-BLOCK
CREATE OR REPLACE FUNCTION crc32(word text)
RETURNS bigint AS $$
DECLARE tmp bigint;
DECLARE i int;
DECLARE j int;
DECLARE byte_length int;
DECLARE word_array bytea;
BEGIN
IF COALESCE(word, '') = '' THEN
return 0;
END IF;

i = 0;
tmp = 4294967295;
byte_length = bit_length(word) / 8;
word_array = decode(replace(word, E'\\\\', E'\\\\\\\\'), 'escape');
LOOP
tmp = (tmp # get_byte(word_array, i))::bigint;
i = i + 1;
j = 0;
LOOP
tmp = ((tmp >> 1) # (3988292384 * (tmp & 1)))::bigint;
j = j + 1;
IF j >= 8 THEN
EXIT;
END IF;
END LOOP;
IF i >= byte_length THEN
EXIT;
END IF;
END LOOP;
return (tmp # 4294967295);
END
$$ IMMUTABLE LANGUAGE plpgsql;
BLOCK
  end

  def down
    execute "DROP FUNCTION IF EXISTS crc32(word test)"
  end
end
