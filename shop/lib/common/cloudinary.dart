const _kCloudName = 'db7wmn9yi';

enum CloudinarySize { thumbnail, medium, original }

/// Строит Cloudinary URL из public_id с нужным размером.
///
/// [thumbnail] — 200×200, crop fill, q_auto, f_auto (для плиток в списке)
/// [medium]    — 480×480, crop fill, q_auto, f_auto (для карточки товара, 2× Retina)
/// [original]  — без трансформации (для полноэкранного просмотра)
String cloudinaryUrl(String publicId, {CloudinarySize size = CloudinarySize.original}) {
  if (publicId.isEmpty) return '';
  final transform = switch (size) {
    CloudinarySize.thumbnail => 'w_200,h_200,c_fill,q_auto,f_auto/',
    CloudinarySize.medium    => 'w_480,h_480,c_fill,q_auto,f_auto/',
    CloudinarySize.original  => '',
  };
  return 'https://res.cloudinary.com/$_kCloudName/image/upload/$transform$publicId';
}
