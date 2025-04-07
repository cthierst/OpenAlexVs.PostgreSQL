\copy(SELECT DISTINCT ON(publication.id)*
FROM publication
JOIN source ON source.id = publication.source_id
JOIN publisher ON publisher.id = source.publisher_id
JOIN author ON author.wos_id = publication.id
JOIN author_address ON author_address.author_id = author.id
JOIN address ON address.id = author_address.address_id
WHERE publication.year = 2019
AND publisher.unified_name ILIKE '%Springer$'
AND address.address ILIKE '%Univ Toronto%' TO 'Pub_Source_Auth_Add.csv' CSV HEADER;
