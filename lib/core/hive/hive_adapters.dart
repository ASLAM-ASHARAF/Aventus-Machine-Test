import 'package:aventus_machine_test/features/posts/data/models/post_model.dart';
import 'package:hive_ce/hive_ce.dart';

@GenerateAdapters([AdapterSpec<PostModel>()])
part 'hive_adapters.g.dart';
