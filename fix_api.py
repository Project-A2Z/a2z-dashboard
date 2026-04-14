import re
with open('lib/core/api_service.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Fix the specific error
text = text.replace(' \$ \', ' \')
text = text.replace(' $ '.replace('$', ''), ' '.replace('$', ''))

# Now remove the block of missing_methods we accidentally added at the end
# because they were duplicates.

with open('lib/core/api_service.dart', 'w', encoding='utf-8') as f:
    f.write(text.replace(' $ ', ' '))
